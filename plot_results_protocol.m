hold on;
close all;
clear all;
clc;

%Use this code to plot the results for simulating VPs on the entire
%protocol

%Load Results
load('UPDATED_1000_RESULTS.mat')

InSilico = RESULTS.InSilico;

% Select the subjects and assign the controller speeds for the respective
% subjects
subs_to_plot = [1:11];
speed5_subs = [1,3,5,7,10];
speed1_subs = [2,4,6,8,9,11];

% Initiate the closed-loop metrics
MDPE = [];
MDAPE = [];
Wobble = [];
per10 = [];
per20 = [];
per30 = [];
risetime = [];
overshoot = [];
settlingtime = [];
settlingstandard = [];
divergence = [];
SSE = [];
tot_inf = [];

% Initiate the closed-loop metrics for two controllers
MDPE_slow = [];
MDAPE_slow = [];
Wobble_slow = [];
per10_slow = [];
per20_slow = [];
per30_slow = [];
risetime_slow = [];
overshoot_slow = [];
settlingtime_slow = [];
settlingstandard_slow = [];
divergence_slow = [];
SSE_slow = [];
tot_inf_slow = [];

% Initiate the closed-loop metrics for fast controllers
MDPE_fast = [];
MDAPE_fast = [];
Wobble_fast = [];
per10_fast = [];
per20_fast = [];
per30_fast = [];
risetime_fast = [];
overshoot_fast = [];
settlingtime_fast = [];
settlingstandard_fast = [];
divergence_fast = [];
SSE_fast = [];
tot_inf_fast = [];

%Compile all Insilico Results
for j=subs_to_plot
    MDPE = [MDPE RESULTS(j).InSilico.MDPE];
    MDAPE = [MDAPE RESULTS(j).InSilico.MDAPE];
    Wobble = [Wobble RESULTS(j).InSilico.Wobble];
    per10 = [per10 RESULTS(j).InSilico.per10];
    per20 = [per20 RESULTS(j).InSilico.per20];
    per30 = [per30 RESULTS(j).InSilico.per30];
    risetime = [risetime RESULTS(j).InSilico.risetime];
    overshoot = [overshoot RESULTS(j).InSilico.overshoot];
    settlingtime = [settlingtime RESULTS(j).InSilico.settlingtime];
    settlingstandard = [settlingstandard RESULTS(j).InSilico.settlingstandard];
    divergence = [divergence RESULTS(j).InSilico.divergence];
    SSE = [SSE RESULTS(j).InSilico.SSE];
    tot_inf = [tot_inf RESULTS(j).InSilico.Infused_Vol];
end

% Compile metrics for slow controller
for j=speed1_subs
    MDPE_slow = [MDPE_slow RESULTS(j).InSilico.MDPE];
    MDAPE_slow = [MDAPE_slow RESULTS(j).InSilico.MDAPE];
    Wobble_slow = [Wobble_slow RESULTS(j).InSilico.Wobble];
    per10_slow = [per10_slow RESULTS(j).InSilico.per10];
    per20_slow = [per20_slow RESULTS(j).InSilico.per20];
    per30_slow = [per30_slow RESULTS(j).InSilico.per30];
    risetime_slow = [risetime_slow RESULTS(j).InSilico.risetime];
    overshoot_slow = [overshoot_slow RESULTS(j).InSilico.overshoot];
    settlingtime_slow = [settlingtime_slow RESULTS(j).InSilico.settlingtime];
    settlingstandard_slow = [settlingstandard_slow RESULTS(j).InSilico.settlingstandard];
    divergence_slow = [divergence_slow RESULTS(j).InSilico.divergence];
    SSE_slow = [SSE_slow RESULTS(j).InSilico.SSE];
    tot_inf_slow = [tot_inf_slow RESULTS(j).InSilico.Infused_Vol];
end

% COmpile metrics for fast controller
for j=speed5_subs
    MDPE_fast = [MDPE_fast RESULTS(j).InSilico.MDPE];
    MDAPE_fast = [MDAPE_fast RESULTS(j).InSilico.MDAPE];
    Wobble_fast = [Wobble_fast RESULTS(j).InSilico.Wobble];
    per10_fast = [per10_fast RESULTS(j).InSilico.per10];
    per20_fast = [per20_fast RESULTS(j).InSilico.per20];
    per30_fast = [per30_fast RESULTS(j).InSilico.per30];
    risetime_fast = [risetime_fast RESULTS(j).InSilico.risetime];
    overshoot_fast = [overshoot_fast RESULTS(j).InSilico.overshoot];
    settlingtime_fast = [settlingtime_fast RESULTS(j).InSilico.settlingtime];
    settlingstandard_fast = [settlingstandard_fast RESULTS(j).InSilico.settlingstandard];
    divergence_fast = [divergence_fast RESULTS(j).InSilico.divergence];
    SSE_fast = [SSE_fast RESULTS(j).InSilico.SSE];
    tot_inf_fast = [tot_inf_fast RESULTS(j).InSilico.Infused_Vol];
end




%Load InVivo Results
InVivo = RESULTS.InVivo;

ind_sub = 1;

% Plot to compare InVivo metrics and InSilico metrics for different
% controllers
figure('units','normalized','outerposition',[0 0 1 1])
subplot(4,3,1)
h = histfit(MDPE,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.MDPE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.MDPE,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlabel('MDPE')
ylabel('No. of Subjects')

subplot(4,3,2)
h = histfit(MDAPE,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.MDAPE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.MDAPE,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlim([0 1])
xlabel('MDAPE')
ylabel('No. of Subjects')

subplot(4,3,3)
h = histfit(Wobble,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.Wobble,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.Wobble,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')

xlabel('Wobble')
ylabel('No. of Subjects')

subplot(4,3,4)
h = histfit(per10,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per10,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per10,'LineWidth',2,'Color','g')
end
xlim([0 100])
legend('InSilico Histogram','InSilico','InVivo')
legend('InSilico','InVivo')
xlabel('Percent of Time around 10% of Target')
ylabel('No. of Subjects')

subplot(4,3,5)
h = histfit(per20,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per20,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per20,'LineWidth',2,'Color','g')
end
xlim([0 100])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Percent of Time around 20% of Target')
ylabel('No. of Subjects')

subplot(4,3,6)
h = histfit(per30,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per30,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per30,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlim([0 100])
xlabel('Percent of Time around 30% of Target')
ylabel('No. of Subjects')

subplot(4,3,7)
h = histfit(risetime,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.risetime,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.risetime,'LineWidth',2,'Color','g')
end
xlim([0 60])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Rise Time (in min)')
ylabel('No. of Subjects')

subplot(4,3,8)
h = histfit(settlingtime,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.settlingtime,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.settlingtime,'LineWidth',2,'Color','g')
end
xlim([0 150])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('First Settling Time (in min)')
ylabel('No. of Subjects')

subplot(4,3,9)
h = histfit(overshoot,100,'exponential');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.overshoot,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.overshoot,'LineWidth',2,'Color','g')
end
xlim([0 120])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Overshoot (mmHg)')
ylabel('No. of Subjects')

subplot(4,3,10)
h = histfit(divergence,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.divergence,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.divergence,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Divergence (%/min)')
ylabel('No. of Subjects')

subplot(4,3,11)
h = histfit(SSE,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.SSE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.SSE,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlabel('SSE (mmHg)')
ylabel('No. of Subjects')

figure('units','normalized','outerposition',[0 0 1 1])
subplot(4,3,1)
h = histfit(MDPE,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.MDPE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.MDPE,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlabel('MDPE')
ylabel('No. of Subjects')

subplot(4,3,2)
h = histfit(MDAPE,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.MDAPE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.MDAPE,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlim([0 1])
xlabel('MDAPE')
ylabel('No. of Subjects')

subplot(4,3,3)
h = histfit(Wobble,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.Wobble,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.Wobble,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')

xlabel('Wobble')
ylabel('No. of Subjects')

subplot(4,3,4)
h = histfit(per10,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per10,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per10,'LineWidth',2,'Color','g')
end
xlim([0 100])
legend('InSilico Histogram','InSilico','InVivo')
legend('InSilico','InVivo')
xlabel('Percent of Time around 10% of Target')
ylabel('No. of Subjects')

subplot(4,3,5)
h = histfit(per20,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per20,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per20,'LineWidth',2,'Color','g')
end
xlim([0 100])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Percent of Time around 20% of Target')
ylabel('No. of Subjects')

subplot(4,3,6)
h = histfit(per30,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per30,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per30,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlim([0 100])
xlabel('Percent of Time around 30% of Target')
ylabel('No. of Subjects')

subplot(4,3,7)
h = histfit(risetime,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.risetime,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.risetime,'LineWidth',2,'Color','g')
end
xlim([0 60])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Rise Time (in min)')
ylabel('No. of Subjects')

subplot(4,3,8)
h = histfit(settlingtime,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.settlingtime,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.settlingtime,'LineWidth',2,'Color','g')
end
xlim([0 150])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('First Settling Time (in min)')
ylabel('No. of Subjects')

subplot(4,3,9)
h = histfit(overshoot,100,'exponential');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.overshoot,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.overshoot,'LineWidth',2,'Color','g')
end
xlim([0 120])
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Overshoot (mmHg)')
ylabel('No. of Subjects')

subplot(4,3,10)
h = histfit(divergence,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.divergence,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.divergence,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlabel('Divergence (%/min)')
ylabel('No. of Subjects')

subplot(4,3,11)
h = histfit(SSE,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.SSE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.SSE,'LineWidth',2,'Color','g')
end
legend('InSilico Histogram','InSilico','InVivo')
xlabel('SSE (mmHg)')
ylabel('No. of Subjects')

%Speed based histograms

figure('units','normalized','outerposition',[0 0 1 1])
subplot(4,3,1)
h = histfit(MDPE_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(MDPE_fast,100);
h(2).Color = [.2 .2 .2];

for i = speed5_subs
    xline(RESULTS(i).InVivo.MDPE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.MDPE,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('MDPE')
ylabel('No. of Subjects')

subplot(4,3,2)
h = histfit(MDAPE_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(MDAPE_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.MDAPE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.MDAPE,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlim([0 1])
xlabel('MDAPE')
ylabel('No. of Subjects')

subplot(4,3,3)
h = histfit(Wobble_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(Wobble_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.Wobble,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.Wobble,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')

xlabel('Wobble')
ylabel('No. of Subjects')

subplot(4,3,4)
h = histfit(per10_slow,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(per10_fast,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per10,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per10,'LineWidth',2,'Color','g')
end
xlim([0 100])
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
legend('InSilico','InVivo')
xlabel('Percent of Time around 10% of Target')
ylabel('No. of Subjects')

subplot(4,3,5)
h = histfit(per20_slow,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(per20_fast,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per20,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per20,'LineWidth',2,'Color','g')
end
xlim([0 100])
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('Percent of Time around 20% of Target')
ylabel('No. of Subjects')

subplot(4,3,6)
h = histfit(per30_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(per30_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.per30,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.per30,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlim([0 100])
xlabel('Percent of Time around 30% of Target')
ylabel('No. of Subjects')

subplot(4,3,7)
h = histfit(risetime_slow,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(risetime_fast,100,'kernel');
h(2).Color = [.2 .2 .2];
hold on;
for i = speed5_subs
    xline(RESULTS(i).InVivo.risetime,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.risetime,'LineWidth',2,'Color','g')
end
xlim([0 60])
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('Rise Time (in min)')
ylabel('No. of Subjects')

subplot(4,3,8)
h = histfit(settlingtime_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(settlingtime_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.settlingtime,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.settlingtime,'LineWidth',2,'Color','g')
end
xlim([0 150])
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('First Settling Time (in min)')
ylabel('No. of Subjects')

subplot(4,3,9)
h = histfit(overshoot_slow,100,'exponential');
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(overshoot_fast,100,'exponential');
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.overshoot,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.overshoot,'LineWidth',2,'Color','g')
end
xlim([0 120])
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('Overshoot (mmHg)')
ylabel('No. of Subjects')

subplot(4,3,10)
h = histfit(divergence_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(divergence_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.divergence,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.divergence,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('Divergence (%/min)')
ylabel('No. of Subjects')

subplot(4,3,11)
h = histfit(SSE_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(SSE_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.SSE,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.SSE,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('SSE (mmHg)')
ylabel('No. of Subjects')

subplot(4,3,12)
h = histfit(tot_inf_slow,100);
h(2).Color = [.2 .2 .2];
hold on;
h = histfit(tot_inf_fast,100);
h(2).Color = [.2 .2 .2];
hold on;

for i = speed5_subs
    xline(RESULTS(i).InVivo.total_inf_vol,'LineWidth',2,'Color','r')
end
hold on;
for i = speed1_subs
    xline(RESULTS(i).InVivo.total_inf_vol,'LineWidth',2,'Color','g')
end
legend('InSilico low speed','Low Speed','InSilico high speed','High Speed')
xlabel('Total Fluid Infusion (L)')
ylabel('No. of Subjects')

q_MDPE_f = quantile(MDPE_fast, [0.05 0.95 1.0]);
q_MDAPE_f = quantile(MDAPE_fast, [0.05 0.95 1.0]);
q_Wobble_f = quantile(Wobble_fast, [0.05 0.95 1.0]);
q_per10_f = quantile(per10_fast, [0.05 0.95 1.0]);
q_per20_f = quantile(per20_fast, [0.05 0.95 1.0]);
q_per30_f = quantile(per30_fast, [0.05 0.95 1.0]);
q_risetime_f = quantile(risetime_fast, [0.05 0.95 1.0]);
q_settlingtime_f = quantile(settlingtime_fast, [0.05 0.95 1.0]);
q_overshoot_f = quantile(overshoot_fast, [0.05 0.95 1.0]);
q_SSE_f = quantile(SSE_fast, [0.05 0.95 1.0]);
q_div_f = quantile(divergence_fast, [0.05 0.95 1.0]);
q_vol_f = quantile(tot_inf_fast, [0.05 0.95 1.0]);

q_MDPE_s = quantile(MDPE_slow, [0.05 0.95 1.0]);
q_MDAPE_s = quantile(MDAPE_slow, [0.05 0.95 1.0]);
q_Wobble_s = quantile(Wobble_slow, [0.05 0.95 1.0]);
q_per10_s = quantile(per10_slow, [0.05 0.95 1.0]);
q_per20_s = quantile(per20_slow, [0.05 0.95 1.0]);
q_per30_s = quantile(per30_slow, [0.05 0.95 1.0]);
q_risetime_s = quantile(risetime_slow, [0.05 0.95 1.0]);
q_settlingtime_s = quantile(settlingtime_slow, [0.05 0.95 1.0]);
q_overshoot_s = quantile(overshoot_slow, [0.05 0.95 1.0]);
q_SSE_s = quantile(SSE_slow, [0.05 0.95 1.0]);
q_div_s = quantile(divergence_slow, [0.05 0.95 1.0]);
q_vol_s = quantile(tot_inf_slow, [0.05 0.95 1.0]);

MDPE_act = [];
MDAPE_act = [];
Wobble_act = [];
per10_act = [];
per20_act = [];
per30_act = [];
risetime_act = [];
settlingtime_act = [];
SSE_act = [];
div_act = [];
vol_act = [];


for i = 1:length(RESULTS)
    MDPE_act = [MDPE_act, RESULTS(i).InVivo.MDPE];  % Concatenate scalar values
end
MDPE_act_f = MDPE_act(speed5_subs);
MDPE_act_s = MDPE_act(speed1_subs);

for i = 1:length(RESULTS)
    MDAPE_act = [MDAPE_act, RESULTS(i).InVivo.MDAPE];  % Concatenate scalar values
end
MDAPE_act_f = MDAPE_act(speed5_subs);
MDAPE_act_s = MDAPE_act(speed1_subs);

for i = 1:length(RESULTS)
    Wobble_act = [Wobble_act, RESULTS(i).InVivo.Wobble];  % Concatenate scalar values
end
Wobble_act_f = Wobble_act(speed5_subs);
Wobble_act_s = Wobble_act(speed1_subs);

for i = 1:length(RESULTS)
    per10_act = [per10_act, RESULTS(i).InVivo.per10];  % Concatenate scalar values
end
per10_act_f = per10_act(speed5_subs);
per10_act_s = per10_act(speed1_subs);

for i = 1:length(RESULTS)
    per20_act = [per20_act, RESULTS(i).InVivo.per20];  % Concatenate scalar values
end
per20_act_f = per20_act(speed5_subs);
per20_act_s = per20_act(speed1_subs);

for i = 1:length(RESULTS)
    per30_act = [per30_act, RESULTS(i).InVivo.per30];  % Concatenate scalar values
end
per30_act_f = per30_act(speed5_subs);
per30_act_s = per30_act(speed1_subs);

for i = 1:length(RESULTS)
    div_act = [div_act, RESULTS(i).InVivo.divergence];  % Concatenate scalar values
end
div_act_f = div_act(speed5_subs);
div_act_s = div_act(speed1_subs);

for i = 1:length(RESULTS)
    risetime_act = [risetime_act, RESULTS(i).InVivo.risetime];  % Concatenate scalar values
end
risetime_act_f = risetime_act(speed5_subs);
risetime_act_s = risetime_act(speed1_subs);

for i = 1:length(RESULTS)
    settlingtime_act = [settlingtime_act, RESULTS(i).InVivo.settlingtime];  % Concatenate scalar values
end
settlingtime_act_f = settlingtime_act(speed5_subs);
settlingtime_act_s = settlingtime_act(speed1_subs);

for i = 1:length(RESULTS)
    SSE_act = [SSE_act, RESULTS(i).InVivo.SSE];  % Concatenate scalar values
end
SSE_act_f = SSE_act(speed5_subs);
SSE_act_s = SSE_act(speed1_subs);

for i = 1:length(RESULTS)
    vol_act = [vol_act, RESULTS(i).InVivo.total_inf_vol];  % Concatenate scalar values
end
vol_act_f = vol_act(speed5_subs);
vol_act_s = vol_act(speed1_subs);

% Calculate results based on quantiles for slow and fast controllers
Q1_MDPE_f = sum(MDPE_act_f <= q_MDPE_f(1));  % Values in the first quartile (<= Q1)
Q2_MDPE_f = sum(MDPE_act_f > q_MDPE_f(1) & MDPE_act_f <= q_MDPE_f(2));  % Q1 < Values <= Q2
Q3_MDPE_f = sum(MDPE_act_f > q_MDPE_f(2) & MDPE_act_f <= q_MDPE_f(3));  % Q2 < Values <= Q3
Q4_MDPE_f = sum(MDPE_act_f > q_MDPE_f(3));  % Values > Q3

Q1_MDPE_s = sum(MDPE_act_s <= q_MDPE_s(1));  % Values in the first quartile (<= Q1)
Q2_MDPE_s = sum(MDPE_act_s > q_MDPE_s(1) & MDPE_act_s <= q_MDPE_s(2));  % Q1 < Values <= Q2
Q3_MDPE_s = sum(MDPE_act_s > q_MDPE_s(2) & MDPE_act_s <= q_MDPE_s(3));  % Q2 < Values <= Q3
Q4_MDPE_s = sum(MDPE_act_s > q_MDPE_s(3));  % Values > Q3

Q1_MDAPE_f = sum(MDAPE_act_f <= q_MDAPE_f(1));  % Values in the first quartile (<= Q1)
Q2_MDAPE_f = sum(MDAPE_act_f > q_MDAPE_f(1) & MDAPE_act_f <= q_MDAPE_f(2));  % Q1 < Values <= Q2
Q3_MDAPE_f = sum(MDAPE_act_f > q_MDAPE_f(2) & MDAPE_act_f <= q_MDAPE_f(3));  % Q2 < Values <= Q3
Q4_MDAPE_f = sum(MDAPE_act_f > q_MDAPE_f(3));  % Values > Q3

Q1_MDAPE_s = sum(MDAPE_act_s <= q_MDAPE_s(1));  % Values in the first quartile (<= Q1)
Q2_MDAPE_s = sum(MDAPE_act_s > q_MDAPE_s(1) & MDAPE_act_s <= q_MDAPE_s(2));  % Q1 < Values <= Q2
Q3_MDAPE_s = sum(MDAPE_act_s > q_MDAPE_s(2) & MDAPE_act_s <= q_MDAPE_s(3));  % Q2 < Values <= Q3
Q4_MDAPE_s = sum(MDAPE_act_s > q_MDAPE_s(3));  % Values > Q3

Q1_Wobble_f = sum(Wobble_act_f <= q_Wobble_f(1));  % Values in the first quartile (<= Q1)
Q2_Wobble_f = sum(Wobble_act_f > q_Wobble_f(1) & Wobble_act_f <= q_Wobble_f(2));  % Q1 < Values <= Q2
Q3_Wobble_f = sum(Wobble_act_f > q_Wobble_f(2) & Wobble_act_f <= q_Wobble_f(3));  % Q2 < Values <= Q3
Q4_Wobble_f = sum(Wobble_act_f > q_Wobble_f(3));  % Values > Q3

Q1_Wobble_s = sum(Wobble_act_s <= q_Wobble_s(1));  % Values in the first quartile (<= Q1)
Q2_Wobble_s = sum(Wobble_act_s > q_Wobble_s(1) & Wobble_act_s <= q_Wobble_s(2));  % Q1 < Values <= Q2
Q3_Wobble_s = sum(Wobble_act_s > q_Wobble_s(2) & Wobble_act_s <= q_Wobble_s(3));  % Q2 < Values <= Q3
Q4_Wobble_s = sum(Wobble_act_s > q_Wobble_s(3));  % Values > Q3

Q1_per10_f = sum(per10_act_f <= q_per10_f(1));  % Values in the first quartile (<= Q1)
Q2_per10_f = sum(per10_act_f > q_per10_f(1) & per10_act_f <= q_per10_f(2));  % Q1 < Values <= Q2
Q3_per10_f = sum(per10_act_f > q_per10_f(2) & per10_act_f <= q_per10_f(3));  % Q2 < Values <= Q3
Q4_per10_f = sum(per10_act_f > q_per10_f(3));  % Values > Q3

Q1_per10_s = sum(per10_act_s <= q_per10_s(1));  % Values in the first quartile (<= Q1)
Q2_per10_s = sum(per10_act_s > q_per10_s(1) & per10_act_s <= q_per10_s(2));  % Q1 < Values <= Q2
Q3_per10_s = sum(per10_act_s > q_per10_s(2) & per10_act_s <= q_per10_s(3));  % Q2 < Values <= Q3
Q4_per10_s = sum(per10_act_s > q_per10_s(3));  % Values > Q3

Q1_per20_f = sum(per20_act_f <= q_per20_f(1));  % Values in the first quartile (<= Q1)
Q2_per20_f = sum(per20_act_f > q_per20_f(1) & per20_act_f <= q_per20_f(2));  % Q1 < Values <= Q2
Q3_per20_f = sum(per20_act_f > q_per20_f(2) & per20_act_f <= q_per20_f(3));  % Q2 < Values <= Q3
Q4_per20_f = sum(per20_act_f > q_per20_f(3));  % Values > Q3

Q1_per20_s = sum(per20_act_s <= q_per20_s(1));  % Values in the first quartile (<= Q1)
Q2_per20_s = sum(per20_act_s > q_per20_s(1) & per20_act_s <= q_per20_s(2));  % Q1 < Values <= Q2
Q3_per20_s = sum(per20_act_s > q_per20_s(2) & per20_act_s <= q_per20_s(3));  % Q2 < Values <= Q3
Q4_per20_s = sum(per20_act_s > q_per20_s(3));  % Values > Q3

Q1_per30_f = sum(per30_act_f <= q_per30_f(1));  % Values in the first quartile (<= Q1)
Q2_per30_f = sum(per30_act_f > q_per30_f(1) & per30_act_f <= q_per30_f(2));  % Q1 < Values <= Q2
Q3_per30_f = sum(per30_act_f > q_per30_f(2) & per30_act_f <= q_per30_f(3));  % Q2 < Values <= Q3
Q4_per30_f = sum(per30_act_f > q_per30_f(3));  % Values > Q3

Q1_per30_s = sum(per30_act_s <= q_per30_s(1));  % Values in the first quartile (<= Q1)
Q2_per30_s = sum(per30_act_s > q_per30_s(1) & per30_act_s <= q_per30_s(2));  % Q1 < Values <= Q2
Q3_per30_s = sum(per30_act_s > q_per30_s(2) & per30_act_s <= q_per30_s(3));  % Q2 < Values <= Q3
Q4_per30_s = sum(per30_act_s > q_per30_s(3));  % Values > Q3

Q1_risetime_f = sum(risetime_act_f <= q_risetime_f(1));  % Values in the first quartile (<= Q1)
Q2_risetime_f = sum(risetime_act_f > q_risetime_f(1) & risetime_act_f <= q_risetime_f(2));  % Q1 < Values <= Q2
Q3_risetime_f = sum(risetime_act_f > q_risetime_f(2) & risetime_act_f <= q_risetime_f(3));  % Q2 < Values <= Q3
Q4_risetime_f = sum(risetime_act_f > q_risetime_f(3));  % Values > Q3

Q1_risetime_s = sum(risetime_act_s <= q_risetime_s(1));  % Values in the first quartile (<= Q1)
Q2_risetime_s = sum(risetime_act_s > q_risetime_s(1) & risetime_act_s <= q_risetime_s(2));  % Q1 < Values <= Q2
Q3_risetime_s = sum(risetime_act_s > q_risetime_s(2) & risetime_act_s <= q_risetime_s(3));  % Q2 < Values <= Q3
Q4_risetime_s = sum(risetime_act_s > q_risetime_s(3));  % Values > Q3

Q1_settlingtime_f = sum(settlingtime_act_f <= q_settlingtime_f(1));  % Values in the first quartile (<= Q1)
Q2_settlingtime_f = sum(settlingtime_act_f > q_settlingtime_f(1) & settlingtime_act_f <= q_settlingtime_f(2));  % Q1 < Values <= Q2
Q3_settlingtime_f = sum(settlingtime_act_f > q_settlingtime_f(2) & settlingtime_act_f <= q_settlingtime_f(3));  % Q2 < Values <= Q3
Q4_settlingtime_f = sum(settlingtime_act_f > q_settlingtime_f(3));  % Values > Q3

Q1_settlingtime_s = sum(settlingtime_act_s <= q_settlingtime_s(1));  % Values in the first quartile (<= Q1)
Q2_settlingtime_s = sum(settlingtime_act_s > q_settlingtime_s(1) & settlingtime_act_s <= q_settlingtime_s(2));  % Q1 < Values <= Q2
Q3_settlingtime_s = sum(settlingtime_act_s > q_settlingtime_s(2) & settlingtime_act_s <= q_settlingtime_s(3));  % Q2 < Values <= Q3
Q4_settlingtime_s = sum(settlingtime_act_s > q_settlingtime_s(3));  % Values > Q3

Q1_SSE_f = sum(SSE_act_f <= q_SSE_f(1));  % Values in the first quartile (<= Q1)
Q2_SSE_f = sum(SSE_act_f > q_SSE_f(1) & SSE_act_f <= q_SSE_f(2));  % Q1 < Values <= Q2
Q3_SSE_f = sum(SSE_act_f > q_SSE_f(2) & SSE_act_f <= q_SSE_f(3));  % Q2 < Values <= Q3
Q4_SSE_f = sum(SSE_act_f > q_SSE_f(3));  % Values > Q3

Q1_SSE_s = sum(SSE_act_s <= q_SSE_s(1));  % Values in the first quartile (<= Q1)
Q2_SSE_s = sum(SSE_act_s > q_SSE_s(1) & SSE_act_s <= q_SSE_s(2));  % Q1 < Values <= Q2
Q3_SSE_s = sum(SSE_act_s > q_SSE_s(2) & SSE_act_s <= q_SSE_s(3));  % Q2 < Values <= Q3
Q4_SSE_s = sum(SSE_act_s > q_SSE_s(3));  % Values > Q3

Q1_vol_f = sum(vol_act_f <= q_vol_f(1));  % Values in the first quartile (<= Q1)
Q2_vol_f = sum(vol_act_f > q_vol_f(1) & vol_act_f <= q_vol_f(2));  % Q1 < Values <= Q2
Q3_vol_f = sum(vol_act_f > q_vol_f(2) & vol_act_f <= q_vol_f(3));  % Q2 < Values <= Q3
Q4_vol_f = sum(vol_act_f > q_vol_f(3));  % Values > Q3

Q1_vol_s = sum(vol_act_s <= q_vol_s(1));  % Values in the first quartile (<= Q1)
Q2_vol_s = sum(vol_act_s > q_vol_s(1) & vol_act_s <= q_vol_s(2));  % Q1 < Values <= Q2
Q3_vol_s = sum(vol_act_s > q_vol_s(2) & vol_act_s <= q_vol_s(3));  % Q2 < Values <= Q3
Q4_vol_s = sum(vol_act_s > q_vol_s(3));  % Values > Q3

Q1_div_f = sum(div_act_f <= q_div_f(1));  % Values in the first quartile (<= Q1)
Q2_div_f = sum(div_act_f > q_div_f(1) & div_act_f <= q_div_f(2));  % Q1 < Values <= Q2
Q3_div_f = sum(div_act_f > q_div_f(2) & div_act_f <= q_div_f(3));  % Q2 < Values <= Q3
Q4_div_f = sum(div_act_f > q_div_f(3));  % Values > Q3

Q1_div_s = sum(div_act_s <= q_div_s(1));  % Values in the first quartile (<= Q1)
Q2_div_s = sum(div_act_s > q_div_s(1) & div_act_s <= q_div_s(2));  % Q1 < Values <= Q2
Q3_div_s = sum(div_act_s > q_div_s(2) & div_act_s <= q_div_s(3));  % Q2 < Values <= Q3
Q4_div_s = sum(div_act_s > q_div_s(3));  % Values > Q3

MDPE_Q_mat = [Q1_MDPE_f Q1_MDPE_s; Q2_MDPE_f Q2_MDPE_s;Q3_MDPE_f Q3_MDPE_s; Q4_MDPE_f Q4_MDPE_s];
MDAPE_Q_mat = [Q1_MDAPE_f Q1_MDAPE_s; Q2_MDAPE_f Q2_MDAPE_s;Q3_MDAPE_f Q3_MDAPE_s; Q4_MDAPE_f Q4_MDAPE_s];
Wobble_Q_mat = [Q1_Wobble_f Q1_Wobble_s; Q2_Wobble_f Q2_Wobble_s;Q3_Wobble_f Q3_Wobble_s; Q4_Wobble_f Q4_Wobble_s];
per10_Q_mat = [Q1_per10_f Q1_per10_s; Q2_per10_f Q2_per10_s;Q3_per10_f Q3_per10_s; Q4_per10_f Q4_per10_s];
per20_Q_mat = [Q1_per20_f Q1_per20_s; Q2_per20_f Q2_per20_s;Q3_per20_f Q3_per20_s; Q4_per20_f Q4_per20_s];
per30_Q_mat = [Q1_per30_f Q1_per30_s; Q2_per30_f Q2_per30_s;Q3_per30_f Q3_per30_s; Q4_per30_f Q4_per30_s];
div_Q_mat = [Q1_div_f Q1_div_s; Q2_div_f Q2_div_s;Q3_div_f Q3_div_s; Q4_div_f Q4_div_s];
risetime_Q_mat = [Q1_risetime_f Q1_risetime_s; Q2_risetime_f Q2_risetime_s;Q3_risetime_f Q3_risetime_s; Q4_risetime_f Q4_risetime_s];
settlingtime_Q_mat = [Q1_settlingtime_f Q1_settlingtime_s; Q2_settlingtime_f Q2_settlingtime_s;Q3_settlingtime_f Q3_settlingtime_s; Q4_settlingtime_f Q4_settlingtime_s];
SSE_Q_mat = [Q1_SSE_f Q1_SSE_s; Q2_SSE_f Q2_SSE_s;Q3_SSE_f Q3_SSE_s; Q4_SSE_f Q4_SSE_s];
vol_Q_mat = [Q1_vol_f Q1_vol_s; Q2_vol_f Q2_vol_s;Q3_vol_f Q3_vol_s; Q4_vol_f Q4_vol_s];
