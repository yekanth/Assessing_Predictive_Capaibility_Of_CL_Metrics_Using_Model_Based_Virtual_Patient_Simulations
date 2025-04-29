function [VP_Inputs,valid,temp_find_when_45] = find_fluid_profile(P_sample,c_start,total_controller_time,Inputs,UMD,FDA,speed,target,Dt)
    
    % Function to eactly replicate the controller input InSilco
    % Use the same function to calculate hemorrhage profile for virtual
    % patients

    if UMD==1
        theta_s = hr_scale_parameters(P_sample);
        W = theta_s(12)*1000/60;
    elseif FDA==1

        %store weight in W
        x = P_sample;

        %FDA model parameters
        A1=x(1);A2=x(2);B_Gain=x(3);B_Loss=x(4);Kp=x(5); 
        Gsv1=x(6);Gsv2=x(7);A3=x(8);SV_Tar = x(9);Kp2=x(10); 
        Kp3=x(11);A4=x(12);TPR0=x(13);BP_Tar=x(14); 
        G1=x(15);G2=x(16);pow1=x(17);pow2=x(18);G3=x(19);Kp4=x(20);Ki4=x(21);HR0=x(22); 
        SV0 = x(23);
        Hct0 = x(24);
        BV0 = x(25);
        W = BV0*1000/60;

        %Provide Physiological Ranges
        min_HC = 0;
        max_HC = 50;
        min_SV = 0;
        max_SV = 0.1;
        min_BP = 0;
        max_BP = 150;
        min_HR = 0;
        max_HR = 300;

        per_valid = 0.0;
        % Change the physiological range based on per_valid 
        min_HC = min_HC-per_valid*min_HC;
        max_HC = max_HC+per_valid*max_HC;
        min_SV = min_SV-per_valid*min_SV;
        max_SV = max_SV+per_valid*max_SV;
        min_BP = min_BP-per_valid*min_BP;
        max_BP = max_BP+per_valid*max_BP;
        min_HR = min_HR-per_valid*min_HR;
        max_HR = max_HR+per_valid*max_HR;
    end

    %Determine Hemorrhage Rate based on the Weight
    H = (0.04022*W-0.1436)/60; %in L/min
    Hd = (0.06183*W+0.2713)/60; %in L/min (disturbance during CL)

    %Load Infusion Rates

    U = [0,0,H];
    
    %Set Simulation Times

    max_sim_time = 120; %in mins
    maintain_time = 15; %in mins
    max_hem_time = 1; %in mins
    gap_btn_hem = 0.5; % in mins

    if UMD==1
        BP0 = theta_s(17);
        CO0 = theta_s(16);
        SV0 = theta_s(18);
        HCT0 = theta_s(15);
        V0 = theta_s(12);
        Va0 = 0.3.*V0;
        Vv0 = 0.7.*V0;
        
        Vr0 = HCT0*(Va0+Vv0);
        
        x0 = [Va0 Vv0 HCT0*V0 0 0 0 0];
        
        % Simulate model
        
        x = x0;
        X = [];
        Y = [];
        
        k = 1;
        BP = BP0; %Initialization
        
        while (BP>45)&&(k<max_sim_time/Dt)% Until MAP goes below 45mmHg simulate

            % Perform transition
            [ x, y ] = hr_transition_model( x, P_sample, U, Dt );
            
            % Save output
            Y(:,k) = y;

            BP = Y(3,end);

            Hemorrhage(k) = H;

            k = k+1;

            % if k>max_sim_time/Dt
            %     break;
            % end

        end
            
            % Implementing On-Off Controller
            U = [0,0,0];
            i = k;
        while i <floor(k+(maintain_time/Dt))

        while (BP>48)&&(i<floor(k+(maintain_time/Dt)))
            U = [0,0,H];
            % Perform transition
            [ x, y ] = hr_transition_model( x, P_sample, U, Dt );
            Hemorrhage(i) = H;
            % Save output
            Y(:,i) = y;
            BP = Y(3,end);
            
            i = i+1;
        end
        m = 1; % at a stretch how much time hemorrhage
        n = 1; % how much time between hemorrhage and hemorrhage
        while (m<floor(max_hem_time/Dt))
            U = [0,0,0];
            % Perform transition
            [ x, y ] = hr_transition_model( x, P_sample, U, Dt );
            Hemorrhage(i) = 0;
            % Save output
            Y(:,i) = y;
            BP = Y(3,end);
            i = i+1;
            m = m+1;
        end
        while n<floor(0.5/Dt)
            U = [0,0,0];
            % Perform transition
            [ x, y ] = hr_transition_model( x, P_sample, U, Dt );
            Hemorrhage(i) = 0;
            % Save output
            Y(:,i) = y;
            BP = Y(3,end);
            i = i+1;
            n = n+1;
        end
        end
    
    if k<max_sim_time/Dt    
        %VP_Inputs.Hemorrhage.Values = -[Hemorrhage -Inputs.Hemorrhage.Values(1,floor(c_start/Dt):end)];
        VP_Inputs.Hemorrhage.Values = -[Hemorrhage zeros(1,20/Dt) Hd*ones(1,5/Dt) zeros(1,15/Dt) Hd*ones(1,5/Dt) zeros(1,15/Dt) Hd*ones(1,5/Dt)];
        VP_Inputs.Infusion.Values = [zeros(1,length(Hemorrhage)) Inputs.Infusion.Values(1,1:floor(c_start/Dt))];
        VP_Inputs.ind_CL_start = length(Hemorrhage);
        VP_Inputs.ind_CL_end = length(VP_Inputs.Hemorrhage.Values);
    else
        VP_Inputs.Hemorrhage.Values= [];
    end

    elseif FDA==1
        %Implement FDA Code
        Urine_inp = 0;
        SamplingTime = Dt;
        T = [ 0.002338735164445   0.000092624863973   0.020141153348763  % Speed 1
          0.003308418154992   0.000196180181788   0.020141153408208  % Speed 2
          0.004294277431407   0.000330145648615   0.020141154335581  % Speed 3
          0.005304511765229   0.000494095579380   0.020141155433024  % Speed 4
          0.006333556190336   0.000688318914970   0.020141156481125  % Speed 5
          0.007375787172632   0.000913107636208   0.020141157419636  % Speed 6
          0.008427216159598   0.001168668833472   0.020141158241748];  % Speed 7
  
        u_max = 2000; %mL/hr
        Kw = 0;
        Kp_control = T(speed,1);
        Ki_control = T(speed,2);
        b_control = T(speed,3);
        ti=100;
        T_end = max_sim_time; % End time [minutes]

        options = simset('SrcWorkspace','current');
        SIMOUT = sim('MAIN_Submitted_to_UMD_V2_PCLC_Sim_Hem',[],options);

        if (length(Hemorrhage)*Dt>max_sim_time)||any(HCT_sol<min_HC)||any(HCT_sol>max_HC)||any(SV_sol<min_SV)||any(SV_sol>max_SV)||any(HR_sol<min_HR)||any(HR_sol>max_HR)||any(BP_sol<min_BP)||any(BP_sol>max_BP)
            valid = 0;
        else
            valid = 1;
        end

        % Store the controller input for the virtual patients 
        VP_Inputs.Hemorrhage.Values = -[-Hemorrhage' Inputs.Hemorrhage.Values(1,floor(c_start/Dt):end)];
        VP_Inputs.Hemorrhage.Values = -[-Hemorrhage' zeros(1,floor(20/Dt)) -Hd*ones(1,floor(5/Dt)) zeros(1,floor(15/Dt)) -Hd*ones(1,floor(5/Dt)) zeros(1,floor(15/Dt)) -Hd*ones(1,floor(5/Dt)) zeros(1,floor(total_controller_time-65)/Dt)];
        %VP_Inputs.Infusion.Values = [zeros(1,length(Hemorrhage)) Inputs.Infusion.Values(1,1:floor(c_start/Dt))];
        VP_Inputs.ind_CL_start = length(Hemorrhage);
        VP_Inputs.ind_CL_end = length(VP_Inputs.Hemorrhage.Values);

        %Sanity Check
        temp_find_when_45 = min(find(Hemorrhage==0));
        temp_find_when_hem_ends = length(Hemorrhage);
        temp_maintain_time = (temp_find_when_hem_ends-temp_find_when_45)/100;
        
        temp_time = 0:1/100:(length(Hemorrhage)-1)/100;
        temp_BP = BP_sol;
        % figure(1)
        % subplot(2,1,1)
        % plot(temp_time,-Hemorrhage)
        % xlabel('Time (min)')
        % ylabel('Hemorrgae Rate (L/min)')
        % 
        % subplot(2,1,2)
        % plot(temp_time,temp_BP)
        % xlabel('Time (min)')
        % ylabel('BP(mmHg)')
        % close all;
        
    
    end


end