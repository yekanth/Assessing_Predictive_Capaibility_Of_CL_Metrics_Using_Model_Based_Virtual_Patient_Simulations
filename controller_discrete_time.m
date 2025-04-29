 % Controller parameters table

 %Speed 2 and Speed 6 are used to conduct experiments

% Y -BP
% r - target
% s- speed
% dt = 1/60 (based on sampling rate of MAP);

function U = run_insilico_controller(Y,r,s)

dt = 1/60; % sampling time (in minutes)

% When the controller first *engages*:
m = 0; % reset memory
w = 0; % initialize anti-windup signal
y0 = Y(1); % save mean arterial pressure

U = [];
M = [];

for k = 1:length(Y) 
    
    % read mean arterial pressure measurement
    y = Y(k); 
    
    % get infusion rate
    [m_next, u_next, w_next] = get_infusion_rate(m, w, y, y0, r, s, dt); 
    
    % replace memory variable values
    m = m_next; 
    w = w_next;
    
    % save simulation
    M = [M m_next];
    U = [U u_next];

end
    
function [m_next, u_next, w_next] = get_infusion_rate(m, w, y, y0, r, s, dt, anti_windup)

    % --------------------------------------------------------   
    
    % Inputs
    % m:  current memory variable
    % y:  current mean arterial pressure (in mmHg)
    % y0: initial mean arterial pressure, when controller engaged (in mmHg)
    % r:  target mean arterial pressure (in mmHg)
    % s:  controller speed setting (integer from 1 to 7)
    % dt: sampling time (in minutes)
    
    % Outputs
    % x_next: next memory variable
    % u_next: next infusion rate (in ml/hour)
    
    % -------------------------------------------------------- 
    
    % Controller parameters table
    
    %     KP                  KI                  b
    T = [ 0.002338735164445   0.000092624863973   0.020141153348763  % Speed 1
          0.003308418154992   0.000196180181788   0.020141153408208  % Speed 2
          0.004294277431407   0.000330145648615   0.020141154335581  % Speed 3
          0.005304511765229   0.000494095579380   0.020141155433024  % Speed 4
          0.006333556190336   0.000688318914970   0.020141156481125  % Speed 5
          0.007375787172632   0.000913107636208   0.020141157419636  % Speed 6
          0.008427216159598   0.001168668833472   0.020141158241748  % Speed 7
        ]; 
      
    % Max Infusion Rate
    u_max = 2000; % ml/hour
    
    % Anti-windup Settings
    KW = 0.5/60/1000; 
    anti_windup = 0;
    if ~anti_windup
        KW = 0;
    end
    
    % Look up controller parameters
    KP = T(s, 1);
    KI = T(s, 2);
    b  = T(s, 3);
    
    % Calculate the next memory variable
    m_next = m + dt*KI*(r-y) + dt*KW*w; % next memory variable
    if ~anti_windup
        m_next = max(m_next, 0);  % enforce lower bound on memory variable
    end
    
    % calculate infusion rate from control law
    u_cont = KP*(b*(r-y0)-(y-y0)) + m; % recommended infusion rate (L/min)
    u_cont = u_cont * 60 * 1000; % convert (L/min) to (ml/hour);
    
    u_sat = max(u_cont, 0);  % enforce lower bound on infusion rate
    u_sat = min(u_sat, u_max); % enforce upper bound on infusion rate
    
    u_next = u_sat;
    w_next = u_sat - u_cont;

end
