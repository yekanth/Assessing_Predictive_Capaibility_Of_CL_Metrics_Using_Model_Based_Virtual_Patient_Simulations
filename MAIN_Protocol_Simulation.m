hold on;
close all;
clear all;
clc;

RMSE_HCT = [];
RMSE_SV = [];
RMSE_HR = [];
RMSE_CO = [];
RMSE_MAP = [];

%Choose which model has to be used 
UMD = 0;
FDA = 1;
subject_specific = 0;

plot_VPs = 0; %Plot Valid VPs
plot_relevant = 0; %Plot Relevant VPs
smooth_BP_HR_noise = 1; %Smooth MAP and HR data
simulate_infusion = 1; %Simulate fluid infusion rate

%Select VPG method
CVI_VPG = 1; % Collective Variational Inference based virtual patient generator
random_VPG = 0; % Randomly generate virtual patients 

c_start_vec = [nan 30.01 31.9 43.98 43.61 90 26.77 ...
    55.27 31.76 nan 36.32 54.75 35.13]; % Vector that stores start time (in min) of controller for each experimental dataset 


Dt = 0.01; % Sampling rate in 1/min

ind_sub = 1; % Start with subject 1

%Initialization


for sidx = [2:9,11:13] % Add subjects [2.3.4.6.7.8.9.11.13] (Some subjects are not used)
    gen_range_hi = 1; % How many standard deviations to randomize for subject generation
    ci_res = 101; % How many valid subjects to generate 
    
    %Hyperparameters
    
    %Estimate Controller Start Time with respect to Hemorrhage Start Time
    %in mins
    
    
    % Load inference results (VP Generator)
    if UMD==1
        load('C:\Users\yekanth\Desktop\Research\FDA vs UMD model comparison\Final_UMD model - SV updated\PCLC VP Generator\RESULTS\CVI_RESULTS_SP_SELECTIVE.mat');
        VARS = RESULTS.VARS;
        var_sizes = RESULTS.var_sizes;
    end

    % Load experimental dataset after Median Filtering (for all 13
    % subjects)
    load('all_compiled_extended_time.mat');
    Experiment = 'HR';
    
    W = DATASET{1,sidx}.Weight; %Weight of the Subject
    target = DATASET{1,sidx}.Controller_Target; %Target MAP
    speed = DATASET{1,sidx}.Controller_Speed; %Speed
    MEASURE_LOSO = DATASET{1,sidx}; %Physiological Measurements
    c_start = c_start_vec(sidx); %Controller Start in mins

    if sidx == 4 % Subject 4 has issue, first measurement is missed
        DATASET{1,sidx}.Measurements.CO.Times(1) = [];
        DATASET{1,sidx}.Measurements.CO.Values(1) = [];
        DATASET{1,sidx}.Measurements.SV.Times(1) = [];
        DATASET{1,sidx}.Measurements.SV.Values(1) = [];
    end
    
    % Define hemorrhage rate in time
    MEASURE_LOSO.Inputs.Hemorrhage.Values = DATASET{1,sidx}.Inputs.Hemorrhage.Values(1:1000:end); %in L/min
    MEASURE_LOSO.Inputs.Hemorrhage.Times = DATASET{1,sidx}.Inputs.Hemorrhage.Times(1:1000:end);
    
    %Interpolate the Hemorrhage Rate to 100 samples per minute
    t_temp = 0:Dt:MEASURE_LOSO.Inputs.Hemorrhage.Times(end)-MEASURE_LOSO.Inputs.Hemorrhage.Times(1);
    MEASURE_LOSO.Inputs.Hemorrhage.Values = interp1(DATASET{1,sidx}.Inputs.Hemorrhage.Times(1:1000:end),DATASET{1,sidx}.Inputs.Hemorrhage.Values(1:1000:end),t_temp+MEASURE_LOSO.Inputs.Hemorrhage.Times(1));
    MEASURE_LOSO.Inputs.Hemorrhage.Times = t_temp+MEASURE_LOSO.Inputs.Hemorrhage.Times(1);
    
    % Interpolate the Infusion rate to 100 samples per minute
    t_temp = 0:Dt:MEASURE_LOSO.Inputs.Infusion.Times(end)-MEASURE_LOSO.Inputs.Infusion.Times(1);
    MEASURE_LOSO.Inputs.Infusion.Values = interp1(DATASET{1,sidx}.Inputs.Infusion.Times(1:end),DATASET{1,sidx}.Inputs.Infusion.Values(1:end),t_temp+MEASURE_LOSO.Inputs.Infusion.Times(1));
    MEASURE_LOSO.Inputs.Infusion.Times = t_temp+MEASURE_LOSO.Inputs.Infusion.Times(1);
    
    %Interpolate MAP and HR to 100 samples per minute
    t_temp = 0:Dt:MEASURE_LOSO.Measurements.MAP.Times(end)-MEASURE_LOSO.Measurements.MAP.Times(1);
    MEASURE_LOSO.Measurements.MAP.Values = interp1(DATASET{1,sidx}.Measurements.MAP.Times,DATASET{1,sidx}.Measurements.MAP.Values,t_temp+MEASURE_LOSO.Measurements.MAP.Times(1));
    MEASURE_LOSO.Measurements.MAP.Times = t_temp+MEASURE_LOSO.Measurements.MAP.Times(1);
    
    MEASURE_LOSO.Measurements.HR.Values = interp1(DATASET{1,sidx}.Measurements.HR.Times,DATASET{1,sidx}.Measurements.HR.Values,t_temp+MEASURE_LOSO.Measurements.HR.Times(1));
    MEASURE_LOSO.Measurements.HR.Times = t_temp+MEASURE_LOSO.Measurements.HR.Times(1);
    
    % Smooth out BP and HR measurements
    if smooth_BP_HR_noise==1
        MEASURE_LOSO.Measurements.MAP.Values = smooth(MEASURE_LOSO.Measurements.MAP.Values,100);
        MEASURE_LOSO.Measurements.MAP.Values = MEASURE_LOSO.Measurements.MAP.Values';
    end
    
    %Sync Infusion and Hemorrhage Vector to start with beginning of
    %Hemorrhage or simply zero padding
    if floor(MEASURE_LOSO.Inputs.Hemorrhage.Times(1))>MEASURE_LOSO.Inputs.Infusion.Times(1)
        time_hem_temp = MEASURE_LOSO.Inputs.Hemorrhage.Times;
        time_inf_temp = MEASURE_LOSO.Inputs.Infusion.Times;
        MEASURE_LOSO.Inputs.Infusion.Times = MEASURE_LOSO.Inputs.Infusion.Times(floor(time_hem_temp(1)/Dt-time_inf_temp(1)/Dt):end);
        MEASURE_LOSO.Inputs.Infusion.Values = MEASURE_LOSO.Inputs.Infusion.Values(floor(time_hem_temp(1)/Dt-time_inf_temp(1)/Dt):end);
        MEASURE_LOSO.Measurements.HR.Times = MEASURE_LOSO.Measurements.HR.Times(floor(time_hem_temp(1)/Dt-time_inf_temp(1)/Dt):end);
        MEASURE_LOSO.Measurements.HR.Values = MEASURE_LOSO.Measurements.HR.Values(floor(time_hem_temp(1)/Dt-time_inf_temp(1)/Dt):end);
        MEASURE_LOSO.Measurements.MAP.Times = MEASURE_LOSO.Measurements.MAP.Times(floor(time_hem_temp(1)/Dt-time_inf_temp(1)/Dt):end);
        MEASURE_LOSO.Measurements.MAP.Values = MEASURE_LOSO.Measurements.MAP.Values(floor(time_hem_temp(1)/Dt-time_inf_temp(1)/Dt):end);
    else
        time_hem_temp = MEASURE_LOSO.Inputs.Hemorrhage.Times;
        time_inf_temp = MEASURE_LOSO.Inputs.Infusion.Times;
        MEASURE_LOSO.Inputs.Infusion.Times = [time_hem_temp(1):Dt:time_inf_temp(1) MEASURE_LOSO.Inputs.Infusion.Times];
        MEASURE_LOSO.Inputs.Infusion.Values = [zeros(1,length(time_hem_temp(1):Dt:time_inf_temp(1))) MEASURE_LOSO.Inputs.Infusion.Values];
    end
    
    % Handle edge case when initial MAP measurement starts after the fluid
    % infusion rate starts 
    if MEASURE_LOSO.Measurements.MAP.Times(1)>MEASURE_LOSO.Inputs.Infusion.Times(1)
        time_MAP_temp = MEASURE_LOSO.Measurements.MAP.Times;
        time_inf_temp = MEASURE_LOSO.Inputs.Infusion.Times;
        MEASURE_LOSO.Inputs.Infusion.Times = MEASURE_LOSO.Inputs.Infusion.Times(floor(time_MAP_temp(1)/Dt-time_inf_temp(1)/Dt):end);
        MEASURE_LOSO.Inputs.Infusion.Values = MEASURE_LOSO.Inputs.Infusion.Values(floor(time_MAP_temp(1)/Dt-time_inf_temp(1)/Dt):end);
    end

    
    % Handle edge case when end of hemorrhage vector is greater than
    % infusion vector
    if MEASURE_LOSO.Inputs.Hemorrhage.Times(end)>MEASURE_LOSO.Inputs.Infusion.Times(end)
        time_hem_temp = MEASURE_LOSO.Inputs.Hemorrhage.Times;
        time_inf_temp = MEASURE_LOSO.Inputs.Infusion.Times;
        MEASURE_LOSO.Inputs.Infusion.Times = [MEASURE_LOSO.Inputs.Infusion.Times time_inf_temp(end)+Dt:Dt:time_hem_temp(end)];
        MEASURE_LOSO.Inputs.Infusion.Values = [MEASURE_LOSO.Inputs.Infusion.Values zeros(1,length(time_inf_temp(end)+Dt:Dt:time_hem_temp(end))) ];
        %MEASURE_LOSO.Measurements.MAP.Times = [MEASURE_LOSO.Measurements.MAP.Times time_inf_temp(end)+Dt:Dt:time_hem_temp(end)];
        %MEASURE_LOSO.Measurements.MAP.Values = [MEASURE_LOSO.Measurements.MAP.Values zeros(1,length(time_inf_temp(end)+Dt:Dt:time_hem_temp(end))) ];
        %MEASURE_LOSO.Measurements.HR.Times = [MEASURE_LOSO.Measurements.HR.Times time_inf_temp(end)+Dt:Dt:time_hem_temp(end)];
        %MEASURE_LOSO.Measurements.HR.Values = [MEASURE_LOSO.Measurements.HR.Values zeros(1,length(time_inf_temp(end)+Dt:Dt:time_hem_temp(end))) ];
    else
        time_hem_temp = MEASURE_LOSO.Inputs.Hemorrhage.Times;
        time_inf_temp = MEASURE_LOSO.Inputs.Infusion.Times;
        MEASURE_LOSO.Inputs.Hemorrhage.Times = [MEASURE_LOSO.Inputs.Hemorrhage.Times time_hem_temp(end)+Dt:Dt:time_inf_temp(end)];
        MEASURE_LOSO.Inputs.Hemorrhage.Values = [MEASURE_LOSO.Inputs.Hemorrhage.Values zeros(1,length(time_hem_temp(end)+Dt:Dt:time_inf_temp(end))) ];
    end
    
    % Handle edge case when length of hemorrhage vector is greater than
    % length of infusion vector
    if length(MEASURE_LOSO.Inputs.Hemorrhage.Values)>length(MEASURE_LOSO.Inputs.Infusion.Values)
        MEASURE_LOSO.Inputs.Infusion.Values = [MEASURE_LOSO.Inputs.Infusion.Values zeros(1,length(MEASURE_LOSO.Inputs.Hemorrhage.Values)-length(MEASURE_LOSO.Inputs.Infusion.Values))];
        MEASURE_LOSO.Inputs.Infusion.Times = MEASURE_LOSO.Inputs.Infusion.Times(1):Dt:MEASURE_LOSO.Inputs.Infusion.Times(1)-Dt+length(MEASURE_LOSO.Inputs.Infusion.Values)*Dt;
    else
        MEASURE_LOSO.Inputs.Hemorrhage.Values = [MEASURE_LOSO.Inputs.Hemorrhage.Values zeros(1,length(MEASURE_LOSO.Inputs.Infusion.Values)-length(MEASURE_LOSO.Inputs.Hemorrhage.Values))];
        MEASURE_LOSO.Inputs.Hemorrhage.Times = MEASURE_LOSO.Inputs.Hemorrhage.Times(1):Dt:MEASURE_LOSO.Inputs.Hemorrhage.Times(1)-Dt+length(MEASURE_LOSO.Inputs.Hemorrhage.Values)*Dt;
    end    
    
    
    
    % Sync Hemorrhage and Infusion Profiles to same time vector 
    % Check the plots (Sanity)
    
    figure(1)
    plot(MEASURE_LOSO.Inputs.Hemorrhage.Times ,MEASURE_LOSO.Inputs.Hemorrhage.Values)
    hold on;
    plot(MEASURE_LOSO.Inputs.Infusion.Times ,MEASURE_LOSO.Inputs.Infusion.Values)

    invivo_inf_vol = trapz(MEASURE_LOSO.Inputs.Infusion.Times ,MEASURE_LOSO.Inputs.Infusion.Values);
    
    close all;

    %Sample VPs using UMD or FDA model (P is VP parameter vector)
    if UMD == 1
        P = model_variational( VARS, var_sizes, zeros(30,18) );
    elseif FDA == 1
        % Just a parameter vector identified previously, selected for
        % sanity check
        P = [-0.0978110000000000	-0.00693550000000000	1.31080000000000	1.21930000000000	0.380720000000000	0.0315820000000000	-0.000185740000000000	-0.000222090000000000	0.0425030000000000	0.000197870000000000	0.0117160000000000	-0.0135560000000000	35.8251152318839	54.1830000000000	0.00170870000000000	1.26370000000000e-05	0.332590000000000	0.583380000000000	0.0194120000000000	0.000746090000000000	0.00107940000000000	90.4859510498922	0.0360245931658267	28.0267593890664	2.89691960272723];
        %P = [ -0.097811   -0.0069355       1.3108       1.2193      0.38072  0.0040247 -0.00070895   -0.0039028     0.055932    0.0034262  0.0055035   -0.0041322   21.878       72.094 0.00027603     0.063916    0.0021302      0.85182 0.038927     0.002109    0.0018671       100.979 MEASURE_LOSO.Measurements.SV.Values(1)/1000 MEASURE_LOSO.Measurements.HCT.Values(1)/100 0.06*MEASURE_LOSO.Weight];
    end
    
    % Simulate the selected subject with most-likely personalized parameters
    if UMD == 1
        Outputs = HR_run_model_m(MEASURE_LOSO.Inputs, P(1,:), c_start, simulate_infusion, target, speed);
    elseif FDA == 1
        Hemorrhage_inp = -MEASURE_LOSO.Inputs.Hemorrhage.Values';
        Urine_inp = zeros(length(Hemorrhage_inp),1);
        SamplingTime = Dt;

        % Parameter vector for FDA's model (check paper)
        x = P;
        A1=x(1);A2=x(2);B_Gain=x(3);B_Loss=x(4);Kp=x(5); 
        Gsv1=x(6);Gsv2=x(7);A3=x(8);SV_Tar = x(9);Kp2=x(10); 
        Kp3=x(11);A4=x(12);TPR0=x(13);BP_Tar=x(14); 
        G1=x(15);G2=x(16);pow1=x(17);pow2=x(18);G3=x(19);Kp4=x(20);Ki4=x(21);HR0=x(22); 
        SV0 = x(23);
        Hct0 = x(24);
        BV0 = x(25);

        % Speed settings 
        T = [ 0.002338735164445   0.000092624863973   0.020141153348763  % Speed 1
          0.003308418154992   0.000196180181788   0.020141153408208  % Speed 2
          0.004294277431407   0.000330145648615   0.020141154335581  % Speed 3
          0.005304511765229   0.000494095579380   0.020141155433024  % Speed 4
          0.006333556190336   0.000688318914970   0.020141156481125  % Speed 5
          0.007375787172632   0.000913107636208   0.020141157419636  % Speed 6
          0.008427216159598   0.001168668833472   0.020141158241748];  % Speed 7
  
        u_max = 2000; %mL/hr
        Kw = 0;

        % 2-DOF PID controller settings
        Kp_control = T(speed,1);
        Ki_control = T(speed,2);
        b_control = T(speed,3);

        % Define time vector
        ti=(length(MEASURE_LOSO.Inputs.Hemorrhage.Values)-1)/100;

        T_end = ti; % End time [minutes]

        % Select options for SImulink
        options = simset('SrcWorkspace','current');
        SIMOUT = sim('MAIN_Submitted_to_UMD_V2_PCLC',[],options);
        %Outputs = HR_run_FDA_model_m(MEASURE_LOSO.Inputs, P(1,:), c_start, target, speed);
        Outputs.HCT = struct('Values', HCT_sol, 'Times', time);
        Outputs.CO  = struct('Values', SV_sol.*HR_sol, 'Times', time);
        Outputs.MAP = struct('Values', BP_sol, 'Times', time);
        Outputs.SV = struct('Values', SV_sol, 'Times', time);
        Outputs.HR = struct('Values', HR_sol, 'Times', time);
        
        Outputs.Infusion = struct('Values', Infusion_PCLC, 'Times', time);
    end
    
    % Get simulated signal length for different measured variables
    hc_length = length(Outputs.HCT.Times);
    co_length = length(Outputs.SV.Times);
    bp_length = length(Outputs.MAP.Times);
    
    simtime_after_hem = floor(hc_length/100);
    
    
    % Respective Subject Measurements (LOSO: Leave-one-subject-out)
    LOSO_HCT = MEASURE_LOSO.Measurements.HCT.Values;
    LOSO_CO = MEASURE_LOSO.Measurements.CO.Values;
    LOSO_MAP = MEASURE_LOSO.Measurements.MAP.Values;
    LOSO_SV = MEASURE_LOSO.Measurements.SV.Values;
    LOSO_HR = MEASURE_LOSO.Measurements.HR.Values;
    
    %Adjust the physiological data according to the availability
    
    while (MEASURE_LOSO.Measurements.HCT.Times(end)-MEASURE_LOSO.Measurements.HCT.Times(1))*100>simtime_after_hem*100
        MEASURE_LOSO.Measurements.HCT.Times = MEASURE_LOSO.Measurements.HCT.Times(1:end-1);
    end
    
    while (MEASURE_LOSO.Measurements.CO.Times(end)-MEASURE_LOSO.Measurements.CO.Times(1))*100>simtime_after_hem*100
        MEASURE_LOSO.Measurements.CO.Times = MEASURE_LOSO.Measurements.CO.Times(1:end-1);
    end
    
    while (MEASURE_LOSO.Measurements.SV.Times(end)-MEASURE_LOSO.Measurements.SV.Times(1))*100>simtime_after_hem*100
        MEASURE_LOSO.Measurements.SV.Times = MEASURE_LOSO.Measurements.SV.Times(1:end-1);
    end

    LOSO_HCT_Times = MEASURE_LOSO.Measurements.HCT.Times*100-MEASURE_LOSO.Measurements.HCT.Times(1)*100+1;
    LOSO_CO_Times = MEASURE_LOSO.Measurements.SV.Times*100-MEASURE_LOSO.Measurements.SV.Times(1)*100+1;
    LOSO_MAP_Times = floor(MEASURE_LOSO.Measurements.MAP.Times*100-MEASURE_LOSO.Measurements.MAP.Times(1)*100+1);
    LOSO_SV_Times = MEASURE_LOSO.Measurements.SV.Times*100-MEASURE_LOSO.Measurements.SV.Times(1)*100+1;
    LOSO_HR_Times = floor(MEASURE_LOSO.Measurements.HR.Times*100-MEASURE_LOSO.Measurements.HR.Times(1)*100+1);
    MEASURE_LOSO.Inputs.Hemorrhage.Times  = MEASURE_LOSO.Inputs.Hemorrhage.Times-MEASURE_LOSO.Inputs.Hemorrhage.Times(1);
    MEASURE_LOSO.Inputs.Infusion.Times  = MEASURE_LOSO.Inputs.Infusion.Times-MEASURE_LOSO.Inputs.Infusion.Times(1);
    
    
    LOSO_HCT = LOSO_HCT(1:length(LOSO_HCT_Times));
    LOSO_CO = LOSO_CO(1:length(LOSO_CO_Times));
    LOSO_SV = LOSO_SV(1:length(LOSO_SV_Times));
    
    %Estimate BV actual from weight of the subject (in L)
    M_BV = W*60/1000 ;
    
    
    
    if UMD == 1
        %Lower and Upper bounds of UMD model parameters
        rlb =  [ -1      -1    -1      0.01     15    2    0         5      0       0      0.001    1     0         25   0.1  1  50  10];
        rub =  [  2       2     4      0.5      100   10   1         100    500     3      0.03     5     0.01      200  0.8  10 180 100];
    elseif FDA == 1
        rlb = [];
        rub = [];
    end
    
    % Simulate the generated subjects
    min_p = 0.9;
    max_p = 1.1;
    
    init_HCT = LOSO_HCT(1);
    init_CO = LOSO_CO(1);
    init_MAP = LOSO_MAP(1);
    init_SV = LOSO_SV(1);
    init_HR = LOSO_HR(1);

    if UMD == 1
        if subject_specific == 1
    
            lb_trunc = [(min_p*(M_BV)-rlb(12))/(rub(12)-rlb(12));(min_p*(init_HCT/100)-rlb(15))/(rub(15)-rlb(15)); (min_p*init_CO(1)-rlb(16))/(rub(16)-rlb(16)); (min_p*init_MAP(1)-rlb(17))/(rub(17)-rlb(17)); (min_p*init_SV(1)-rlb(18))/(rub(18)-rlb(18)) ];

            ub_trunc = [(max_p*(M_BV)-rlb(12))/(rub(12)-rlb(12));(max_p*(init_HCT/100)-rlb(15))/(rub(15)-rlb(15)); (max_p*init_CO(1)-rlb(16))/(rub(16)-rlb(16)); (max_p*init_MAP(1)-rlb(17))/(rub(17)-rlb(17)); (max_p*init_SV(1)-rlb(18))/(rub(18)-rlb(18)) ];
    
            %Customizing Initial Values parameters to subject-specific values
            lb = [zeros(11,1); lb_trunc(1); zeros(2,1);lb_trunc(2:5,:)];
            ub = [gen_range_hi*ones(11,1);ub_trunc(1);  gen_range_hi*ones(2,1); ub_trunc(2:5,:)];
        else
            lb = zeros(18,1);
            ub = gen_range_hi*ones(18,1);
        end
    end

    
   
    i = 1; % Total VPs
    j = 1; % 
    v = 0; % Physiologically valid VPs

    
    %Counting number of invalid physiological responses (store the index)
    ind_invalid = [];
    ind_valid = [];
    
    %Provide Physiological Ranges
    if UMD==1
        min_HC = 0; %fraction
        max_HC = 0.5;
        min_SV = 0; %L/min
        max_SV = 100;
        min_BP = 0; %mmHg
        max_BP = 150;
        min_HR = 0; %bpm
        max_HR = 300;
    elseif FDA==1
        min_HC = 0;
        max_HC = 0.5*100;
        min_SV = 0;
        max_SV = 100/1000;
        min_BP = 0;
        max_BP = 150;
        min_HR = 0;
        max_HR = 300;
    end
    
    % Percentage of valid range
    per_valid = 0;

    min_HC = min_HC-per_valid*min_HC;
    max_HC = max_HC+per_valid*max_HC;
    min_SV = min_SV-per_valid*min_SV;
    max_SV = max_SV+per_valid*max_SV;
    min_BP = min_BP-per_valid*min_BP;
    max_BP = max_BP+per_valid*max_BP;
    min_HR = min_HR-per_valid*min_HR;
    max_HR = max_HR+per_valid*max_HR;
    
    
    %Find CL Start and End Samples through the Measured Infusion Rate
    
    ind_CL_start = floor(c_start/Dt);
    
    if length(MEASURE_LOSO.Inputs.Infusion.Values)>length(MEASURE_LOSO.Measurements.MAP.Values)
        ind_CL_end = length(MEASURE_LOSO.Measurements.MAP.Values);
    else
        ind_CL_end = length(MEASURE_LOSO.Inputs.Infusion.Values);
    end
    
    % Calculate total controller time
    total_controller_time = (ind_CL_end-ind_CL_start)*Dt;
    
    %Calculate and Store CL metrics of actual experimental data
    
    InVivo{ind_sub} = evaluate_CL_metrics(ind_CL_start,ind_CL_end,MEASURE_LOSO.Inputs.Hemorrhage.Values,MEASURE_LOSO.Measurements.MAP.Values,MEASURE_LOSO.Measurements.MAP.Times-MEASURE_LOSO.Measurements.MAP.Times(1),target,invivo_inf_vol,Dt,0);
    
    if FDA==1
        base_file = '_traditional_Validation';
        current_file = ['Subject',num2str(sidx),base_file,'.mat'];
        load(current_file,'P');
    end
            
    while (v < ci_res)
        if UMD==1
            VP_Inputs.Hemorrhage.Values = [];
            while isempty(VP_Inputs.Hemorrhage.Values)
                if (CVI_VPG==1)&&(random_VPG==0)
                    [P_sample] = model_generative_constrained( VARS, var_sizes, lb, ub);
                elseif (random_VPG==1)&&(CVI_VPG==0)
                    P_sample = rand(1,length(lb));
                end
                % Find the respective Hemorrhage Profile
                
                VP_Inputs = find_fluid_profile(P_sample,c_start,MEASURE_LOSO.Inputs,UMD,FDA,Dt);
            
            end
            SampleOutputs = HR_run_model_m(VP_Inputs, P_sample, (VP_Inputs.ind_CL_start)*Dt, simulate_infusion, target, speed);
        elseif FDA==1
            
            
            P_sample = P(i,:);

            % Find the respective Hemorrhage Profile
               
            [VP_Inputs,valid,time_when_45] = find_fluid_profile(P_sample,c_start,total_controller_time,MEASURE_LOSO.Inputs,UMD,FDA,speed,target,Dt);
            Hemorrhage_inp = VP_Inputs.Hemorrhage.Values;
            Init_BV_loss = Hemorrhage_inp(1)*min(find(Hemorrhage_inp==0))/100;
            Urine_inp = zeros(length(Hemorrhage_inp),1); 
            c_start = VP_Inputs.ind_CL_start*Dt;
            % if ~valid
            %     i = i+1;
            %     continue
            % end

            x = P_sample;
            A1=x(1);A2=x(2);B_Gain=x(3);B_Loss=x(4);Kp=x(5); 
            Gsv1=x(6);Gsv2=x(7);A3=x(8);SV_Tar = x(9);Kp2=x(10); 
            Kp3=x(11);A4=x(12);TPR0=x(13);BP_Tar=x(14); 
            G1=x(15);G2=x(16);pow1=x(17);pow2=x(18);G3=x(19);Kp4=x(20);Ki4=x(21);HR0=x(22); 
            SV0 = x(23);
            Hct0 = x(24);
            BV0 = x(25);
            
            ti=(length(Hemorrhage_inp)-1)/100;
            T_end = ti; % End time [minutes]

            options = simset('SrcWorkspace','current');
            SIMOUT = sim('MAIN_Submitted_to_UMD_V2_PCLC',[],options);

            SampleOutputs.HCT = struct('Values', HCT_sol, 'Times', time);
            SampleOutputs.CO  = struct('Values', SV_sol.*HR_sol, 'Times', time);
            SampleOutputs.MAP = struct('Values', BP_sol, 'Times', time);
            SampleOutputs.SV = struct('Values', SV_sol, 'Times', time);
            SampleOutputs.HR = struct('Values', HR_sol, 'Times', time);
            SampleOutputs.BV = struct('Values',BV_sol+BV0,'Times',time);
            
            SampleOutputs.Infusion = struct('Values', Infusion_PCLC, 'Times', time);

        end
        len = length(SampleOutputs.HCT.Values); 
        
        % Calculated hemodynamics profile and blood volume profile
        S_HC = SampleOutputs.HCT.Values;
        S_CO = SampleOutputs.CO.Values;
        S_BP = SampleOutputs.MAP.Values;
        S_SV = SampleOutputs.SV.Values;
        S_HR = SampleOutputs.HR.Values;
        S_BV = SampleOutputs.BV.Values;
        
        % Calculated infusion profile
        S_Infusion = SampleOutputs.Infusion.Values;
        

        VP_Times = 0:Dt:(length(S_Infusion)-1)*Dt;
            
        S_Infused_Vol = trapz(VP_Times,S_Infusion); %Infused vol in L

        % Write new conditions for SV, BP and HR (if <threshold for >5mins)
        variable_BP = 0;
        variable_SV = 0;
        variable_HR = 0;

        n = 5; %in mins
        threshold_SV = 0;
        count = 0;
        
        % Check if SV is less than threshold for more than 5 mins
        for pq = 1:length(S_SV)
            if (S_SV(pq) < threshold_SV)
                count = count + 1;
                if count >= n/Dt
                    variable_SV = 1;
                    break;
                end
                count = 0;
            end
        end

        % Check if BP is less than threshold for more than 5 mins
        threshold_BP = 0;
        count = 0;
        for pq = 1:length(S_BP)
            if S_BP(pq) < threshold_BP
                count = count + 1;
                if count >= n/Dt
                    variable_BP = 1;
                    break;
                end
            else
                count = 0;
            end
        end
        
        % Check if HR is less than threshold for more than 5 mins
        threshold_HR = 0;
        count = 0;
        for pq = 1:length(S_HR)
            if S_HR(pq) < threshold_HR
                count = count + 1;
                if count >= n/Dt
                    variable_HR = 1;
                    break;
                end
            else
                count = 0;
            end
        end


        % Check if the subject is in physiologically valid range

        if isempty(find(S_HC<min_HC))&&isempty(find(S_HC>max_HC))&&(~variable_SV)&&isempty(find(S_SV>max_SV))&&(~variable_BP)&&isempty(find(S_BP>max_BP))&&(~variable_HR)&&isempty(find(S_HR>max_HR))&&isempty(find(S_BV<0.1*BV0))&&(S_BP(time_when_45)<48)&&(S_Infused_Vol>0.1)&&(S_BP(1)>65)&&(min(S_BP)>-30)
            ind_valid = [ind_valid;i];
            
            % Calculate the closed-loop metrics

            temp_compile = evaluate_CL_metrics(VP_Inputs.ind_CL_start,VP_Inputs.ind_CL_end,VP_Inputs.Hemorrhage.Values,S_BP,0:Dt:length(S_BP)-Dt,target,S_Infused_Vol,Dt,FDA);
            
            % Store the controller metrics

            MDPE_Silico(length(ind_valid)) = temp_compile.MDPE;
            MDAPE_Silico(length(ind_valid)) = temp_compile.MDAPE;
            Wobble_Silico(length(ind_valid)) = temp_compile.Wobble;
            per10_Silico(length(ind_valid)) = temp_compile.per10;
            per20_Silico(length(ind_valid)) = temp_compile.per20;
            per30_Silico(length(ind_valid)) = temp_compile.per30;
            SSE_Silico(length(ind_valid)) = temp_compile.SSE;
            Inf_Silico(length(ind_valid)) = temp_compile.total_inf_vol;
                
            if ~isempty(temp_compile.risetime)
                risetime_Silico(length(ind_valid)) = temp_compile.risetime;
            else
                risetime_Silico(length(ind_valid)) = NaN;
            end
                
            overshoot_Silico(length(ind_valid)) = temp_compile.overshoot;
            undershoot_Silico(length(ind_valid)) = temp_compile.undershoot;
            settling_Silico(length(ind_valid)) = temp_compile.settlingtime;
            settlingstandard_Silico(length(ind_valid)) = temp_compile.settlingstandard;
            divergence_Silico(length(ind_valid)) = temp_compile.divergence;
            max_overshoot_BP(length(ind_valid)) = temp_compile.max_overshoot_BP;
                
            if plot_VPs == 1
                figure('units','normalized','outerposition',[0 0 1 1])

                % Plot Inputs ------------------------------------------------------------

                subplot(2,3,1);
                plot(VP_Times, S_Infusion,'-k','LineWidth',1);hold on;
                plot(VP_Times, -VP_Inputs.Hemorrhage.Values,'-.r','LineWidth',1); hold on;
                legend('Simulated Infusion','Hemorrhage')
                xlabel('Time (min)'); ylabel('Fluid I/O (L/min)');
                set(gca,'fontsize',10); set(gca,'XLim',[0 VP_Times(end)],'XTick',[0:30:VP_Times(end)])
                grid on;

                % Plot Virtual Subject Responses -----------------------------------------

                subplot(2,3,2);
                hold on;
                plot(VP_Times,S_HC)
                set(gca,'XTick',[0:30:VP_Times(end)]);%ylim([0 80])
                ylabel('Hematocrit (%)'); xlabel('Time (min)');
                set(gca,'fontsize',10); set(gca,'XLim',[0 VP_Times(end)],'XTick',[0:30:VP_Times(end)])
                axis on; grid on; box on;

                subplot(2,3,3);
                hold on;
                plot(VP_Times,S_HR,'LineWidth',2)
                set(gca,'XTick',[0:30:VP_Times(end)]);%ylim([0 80])
                ylabel('Heart Rate (bpm)'); xlabel('Time (min)');
                set(gca,'fontsize',10); set(gca,'XLim',[0 VP_Times(end)],'XTick',[0:30:VP_Times(end)])
                axis on; grid on; box on;

                subplot(2,3,4);
                hold on;
                plot(VP_Times,S_SV,'LineWidth',2)
                set(gca,'XTick',[0:30:VP_Times(end)]);%ylim([0 80])
                ylabel('Stroke Volume (L)'); xlabel('Time (min)');
                set(gca,'fontsize',10); set(gca,'XLim',[0 VP_Times(end)],'XTick',[0:30:VP_Times(end)])
                axis on; grid on; box on;

                subplot(2,3,5);
                hold on;
                plot(VP_Times,S_CO,'LineWidth',2)
                set(gca,'XTick',[0:30:VP_Times(end)]);%ylim([0 80])
                ylabel('Cardiac Output (L/min)'); xlabel('Time (min)');
                set(gca,'fontsize',10); set(gca,'XLim',[0 VP_Times(end)],'XTick',[0:30:VP_Times(end)])
                axis on; grid on; box on;

                subplot(2,3,6);
                hold on;
                plot(VP_Times,S_BP,'LineWidth',2)
                set(gca,'XTick',[0:30:VP_Times(end)]);%ylim([0 80])
                ylabel('MAP (mmHg)'); xlabel('Time (min)');
                set(gca,'fontsize',10); set(gca,'XLim',[0 VP_Times(end)],'XTick',[0:30:VP_Times(end)])
                axis on; grid on; box on;

            end
            
            % Define and store exclusion criterion
            exclusion1 = 0;
            exclusion2 = 0;
            exclusion3 = 0;
            exclusion4 = 0;
            exclusion5 = 0;
            exclusion6 = 0;
            exclusion7 = 0;

            if isempty(temp_compile.risetime)
                temp_compile.risetime = NaN;
            end
            
            % Store a matrix for sharing with Dr. Scully as per his request
            dr_scully_mat(v+1,:,sidx) = [i,sidx,speed,1000*S_BV(1)/60,S_BV(1),S_HC(1),S_CO(1),S_BP(1),S_HR(1),Init_BV_loss,min(S_HC),temp_compile.MDPE,temp_compile.MDAPE,temp_compile.Wobble,temp_compile.per10,temp_compile.per20,temp_compile.per30,temp_compile.risetime,temp_compile.overshoot,temp_compile.max_overshoot_BP,temp_compile.undershoot,temp_compile.settlingtime,temp_compile.divergence,temp_compile.SSE,temp_compile.total_inf_vol,exclusion1,exclusion2,exclusion3,exclusion4,exclusion5,exclusion6,exclusion7];


            v = v+1;
            i = i+1;

            fprintf('Subject: %d\n', sidx);
            fprintf('Valid Sample: %d\n', v);
            else 
            ind_invalid = [ind_invalid;i];



            i = i+1;

            fprintf('Subject: %d\n', sidx);
            fprintf('Sample: %d\n', i);
            end
        j = j+1;
        
 
    end

    % Store the results for each subject
    InSilico{ind_sub} = struct('MDPE',MDPE_Silico,'MDAPE',MDAPE_Silico,'Wobble',Wobble_Silico,'per10',per10_Silico,'per20',per20_Silico,'per30',per30_Silico,'risetime',risetime_Silico,'overshoot',overshoot_Silico,'undershoot',undershoot_Silico,'settlingtime',settling_Silico,'settlingstandard',settlingstandard_Silico,'divergence',divergence_Silico,'SSE',SSE_Silico,'Infused_Vol',Inf_Silico,'max_overshoot_BP',max_overshoot_BP);
    
    clearvars PE_Silico MDPE_Silico MDAPE_Silico Wobble_Silico per10_Silico per20_Silico per30_Silico risetime_Silico overshoot_Silico undershoot_Silico settling_Silico settlingstandard_Silico divergence_Silico SSE_Silico Inf_Silico max_overshoot_BP
    
    ind_sub = ind_sub+1;

end

% Store all the results in a structure
RESULTS = struct('InSilico',InSilico,'InVivo',InVivo);
    