function compile = evaluate_CL_metrics(ind_CL_start,ind_CL_end,Hemorrhage,MAP,Times,target,invivo_inf_vol,Dt,FDA)
    
    for ind_CL_sample = 1:ind_CL_end-ind_CL_start
        PE(ind_CL_sample) = (MAP(ind_CL_sample)-target)/target;
    end
    
    %Calculate  CL metrics
    
    MDPE = median(PE);
    MDAPE = median(abs(PE));
    Wobble = median(abs(PE-MDPE));
    
    per10 = length(find(abs(MAP(ind_CL_start:ind_CL_end)-target)<0.1*target))*100/(ind_CL_end-ind_CL_start+1);
    per20 = length(find(abs(MAP(ind_CL_start:ind_CL_end)-target)<0.2*target))*100/(ind_CL_end-ind_CL_start+1);
    per30 = length(find(abs(MAP(ind_CL_start:ind_CL_end)-target)<0.3*target))*100/(ind_CL_end-ind_CL_start+1);
    
    %Divergence
    t_temp = 0:1/100:(length(PE)-1)/100;
    divergence = (sum(abs(PE).*t_temp)-(sum(abs(PE)))*mean(t_temp))/(sum(t_temp.*t_temp) - ((sum(t_temp))^2)/length(t_temp));
    
    when_greater_than_target = find(MAP(ind_CL_start:ind_CL_end)>=target);
    
    %Calculating Settling Time
    error_tol = 0.1;
    
    %Calculating all the metrics using MATLAB function
    step_metrics = stepinfo(MAP(ind_CL_start:ind_CL_end),1:1:length(MAP(ind_CL_start:ind_CL_end)),target,'SettlingTimeThreshold',error_tol);
    
    risetime_t = step_metrics.RiseTime*Dt;
    settling_standard = step_metrics.SettlingTime*Dt;
    overshoot_t = step_metrics.Overshoot;
    undershoot_t = step_metrics.Undershoot;

    %Risetime
    MAP_focus = MAP(ind_CL_start:ind_CL_end);
    if MAP_focus(1)<target
        risetime = (min(find(round(MAP_focus,1)>=round(MAP_focus(1)+0.9*(target-MAP_focus(1)),1)))-min(find(round(MAP_focus,1)>=round(MAP_focus(1)+0.1*(target-MAP_focus(1)),1))))*Dt;
    else
        risetime = nan;
    end

    %Steady State Error
    window = 2; %in mins
    Hemorrhage = smooth(Hemorrhage,20);
    if FDA==1
        Hemorrhage = -Hemorrhage;
    end
     
    end_hem_ind = max(find(round(Hemorrhage,2)<0));
    last_hem_ind = length(Hemorrhage);
    
    if (last_hem_ind-end_hem_ind)*Dt>10
        sse = mean(MAP(ind_CL_end-window/Dt:ind_CL_end))-target;
    else
        ind_temp = find(Hemorrhage<0);
        p = 0;
        while round(Hemorrhage(max(find(Hemorrhage(1:end_hem_ind-p-250)))),2)~=0
            cut_last_hem = end_hem_ind - p - 250;
            p = p+1;
        end
        sse = mean(MAP(cut_last_hem-window/Dt:cut_last_hem))-target;
    end

    %plot(Hemorrhage)

    
    %Overshoot
    max_response = max(MAP_focus);
    overshoot_aux = 100*(max_response-target)/target;
    max_overshoot_BP = max_response;
    if overshoot_aux<=0
        overshoot_aux = nan;
        max_overshoot_BP = max_response;
    end
    overshoot = overshoot_aux; 

    %Undershoot
    min_response = min(MAP_focus);
    undershoot_aux = 100*(target-min_response)/target;
    min_undershoot_BP = min_response;
    if undershoot_aux<=0
        undershoot_aux = nan;
        min_undershoot_BP = min_response;
    end
    undershoot = undershoot_aux;

   
    
    
    
    buffer = 0.9;
    settling = NaN;
    



    % settling time
    signal = MAP(ind_CL_start:ind_CL_end);
    t = Times(ind_CL_start:ind_CL_end);
    settling_duration_threshold = 10; % min
    PF = (abs(signal - target))/target;
    settling_indices = find(PF <= error_tol);
    % Find consecutive groups of indices with durations more than 10 seconds
%     diff_indices = diff(settling_indices);
%     group_start_indices = [settling_indices(1), settling_indices(find(diff_indices > 1)+ 1) ];
    if ~isempty(settling_indices)
        group_start_indices = [];
        for i = 1:length(settling_indices)
            current_index = settling_indices(i);
            past_index = current_index - 1;

            % Check if the next index is within the same group and greater than the threshold
            if past_index >settling_indices(1) && PF(past_index) > error_tol
                group_start_indices = [group_start_indices, past_index];
            end
        end
        group_start_indices = [settling_indices(1) group_start_indices];


        group_end_indices = [];
        % Loop through the settling_indices
        for i = 1:length(settling_indices)
            current_index = settling_indices(i);
            next_index = current_index + 1;

            % Check if the next index is within the same group and greater than the threshold
            if next_index < settling_indices(end) && PF(next_index) > error_tol
                group_end_indices = [group_end_indices, next_index];
            end
        end
        group_end_indices = [group_end_indices settling_indices(end)];

        settling_durations = t(group_end_indices) - t(group_start_indices);
        settling_groups = group_start_indices(settling_durations >= settling_duration_threshold);
        if ~isempty(settling_groups)
            start_time = t(settling_groups(1));%start_time
            end_time = t(group_end_indices(group_start_indices == settling_groups(1)));
        else
            start_time = nan;
        end
        settling=start_time;
    else
        settling = nan;
    end
    
    settling = settling;
    
    compile = struct('MDPE',MDPE,'MDAPE',MDAPE,'Wobble',Wobble,'per10',per10,'per20',per20,'per30',per30,'risetime',risetime,'overshoot',overshoot,'undershoot',undershoot,'settlingtime',settling,'settlingstandard',settling_standard,'divergence',divergence,'SSE',sse,'total_inf_vol',invivo_inf_vol,'max_overshoot_BP',max_overshoot_BP);
    

end