format long;
close all;
clear;
clc;

%% Physical Constants
c = 299792458;
me = 9.1093829e-31;
e = 1.602176565e-19;
u = 1.660538921e-27;
epsilon_0 = 8.854187817e-12;

FolderName = 'Profile_data';
if ~exist(FolderName, "dir")
    mkdir(FolderName);
end

w = 2*pi*4.6e9;
N_para = -2.04;
k_para = N_para*w/c;

Tc = 0.5*me*(w/k_para/3)^2/e/1e3;

%% Hybrid senerio
load('CFETR_Hybrid.mat');
%----------------Electron----------------%
Ps(1).Name = 'Electron';
Ps(1).q = -1;
Ps(1).m = me;
Ps(1).n0 = ELECTRON.density;
Ps(1).T = ELECTRON.temperature*1e3;
%----------------Deuterium----------------%
Ps(2).Name = 'Deuterium';
Ps(2).q = 1;
Ps(2).m = 2*u;
Ps(2).n0 = IONS_1.density;
Ps(2).T = IONS_1.temperature*1e3;
%----------------Tritium----------------%
Ps(3).Name = 'Tritium';
Ps(3).q = 1;
Ps(3).m = 3*u;
Ps(3).n0 = IONS_2.density;
Ps(3).T = IONS_2.temperature*1e3;
%----------------Helium----------------%
Ps(4).Name = 'Cold Helium';
Ps(4).q = 2;
Ps(4).m = 4*u;
Ps(4).n0 = IONS_3.density;
Ps(4).T = IONS_3.temperature*1e3;
%----------------Argon----------------%
Ps(5).Name = 'Argon';
Ps(5).q = 18;
Ps(5).m = 40*u;
Ps(5).n0 = IONS_4.density;
Ps(5).T = IONS_4.temperature*1e3;
%----------------NBI Deuterium----------------%
Ps(6).Name = 'NBI Deuterium';
Ps(6).q = 1;
Ps(6).m = 2*u;
Ps(6).n0 = IONS_5.density;
Ps(6).T = IONS_5.temperature*1e3;
%----------------Fast Alpha----------------%
% T
Ps(7).Name = 'Fast Alpha';
Ps(7).q = 2;
Ps(7).m = 4*u;
Ps(7).n0 = IONS_6.density;
Ps(7).T = IONS_6.temperature*1e3;
% Correction of CFETR NBI energy
Ps(6).T(176:end) = Ps(6).T(175);
% Neutralize
Qe = abs(Ps(1).q)*Ps(1).n0;
Qi = 0;
for k = 2:numel(Ps)
    Qi = Qi + Ps(k).q*Ps(k).n0;
end
errormax = 1e-5;
itertime = 0;
OK = all(abs(Qe - Qi) < errormax*Qe, 'all');
if ~OK && itertime < 1000
    itertime = itertime + 1;
    QeQi = Qe./Qi;
    Qi = 0;
    for k = 2:numel(Ps)
        Ps(k).n0 = Ps(k).n0.*QeQi;
        Qi = Qi + Ps(k).q*Ps(k).n0;
    end
    OK = all(abs(Qe - Qi) < errormax*Qe, 'all');
end
fprintf('Iter time = %d\n', itertime);

% Load gfile
G = loadGfile('gfile_Hybrid');
save([FolderName, '/CFETR_Neut_Hybrid.mat'], "c", "e", "me", "u", "epsilon_0", "rho", "Ps", "G");

% Plot senerio
F = figure;
hold on;
plot(rho, Ps(1).n0/1e19, 'LineWidth', 1, 'DisplayName', 'Electron');
plot(rho, Ps(2).n0/1e19, 'LineWidth', 1, 'DisplayName', 'Deuterium');
plot(rho, Ps(3).n0/1e19, 'LineWidth', 1, 'DisplayName', 'Tritium');
xlabel('$\rho$', 'Interpreter', 'latex');
ylabel('$n_0 / 10^{19}m^{-3}$', 'Interpreter', 'latex');
legend('Location', 'southwest', 'Interpreter', 'latex');
title('Density profile of CFETR hybrid senerio', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
savefig(F, [FolderName, '/Hybrid_Density.fig']);
saveas(F, [FolderName, '/Hybrid_Density.png']);

F = figure;
hold on;
plot(rho, Ps(1).T/1e3, 'LineWidth', 1, 'DisplayName', 'Electron');
plot(rho, Ps(1).T/1e3, 'LineWidth', 1, 'DisplayName', 'Deuterium');
plot(rho, Ps(1).T/1e3, 'LineWidth', 1, 'DisplayName', 'Tritium');
xlabel('$\rho$', 'Interpreter', 'latex');
ylabel('$T / keV$', 'Interpreter', 'latex');
legend('Location', 'southwest', 'Interpreter', 'latex');
title('Temperature profile of CFETR hybrid senerio', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
savefig(F, [FolderName, '/Hybrid_Temperature.fig']);
saveas(F, [FolderName, '/Hybrid_Temperature.png']);


F = figure;
hold on;
imagesc(G.R, G.Z, G.Brz);
plot(G.Rbound, G.Zbound, 'r-', 'LineWidth', 1, 'DisplayName', 'LCFS');
legend;
axis equal;
set(gca, 'YDir', 'Normal');
xlabel('$R/m$', 'Interpreter', 'latex');
ylabel('$Z/m$', 'Interpreter', 'latex');
C = colorbar;
C.Label.String = '$B/T$';
C.Label.Interpreter = 'latex';
title('B field of CFETR hybrid henerio', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
savefig(F, [FolderName, '/B_Hybrid.fig']);
saveas(F, [FolderName, '/B_Hybrid.png']);







Nsam = 181;
P = Ps;
for k = 1:numel(P)
    P(k).T = Ps(k).T(Nsam);
    P(k).n0 = Ps(k).n0(Nsam);
end

MaxIter = 40;
kacc0 = Kacc(w, B0, P);
kacc = kacc0;
P0 = P;
Iter = 1;
Fac = (abs(k_para)/kacc + 1)/2;
while 1.05*kacc < abs(k_para) && Iter < MaxIter
    kacc0 = kacc;
    P0 = P;
    for k = 1:numel(P)
        P(k).n0 = P(k).n0*Fac;
    end
    kacc = Kacc(w, B0, P);
    Iter = Iter + 1;
    Fac = (abs(k_para)/kacc + 1)/2;
end

FacN_Hybrid = P0(1).n0/Ps(1).n0(Nsam);




%% Steady State Senerio
load('CFETR_Steady.mat');
%----------------Electron----------------%
Ps(1).Name = 'Electron';
Ps(1).q = -1;
Ps(1).m = me;
Ps(1).n0 = ELECTRON.density;
Ps(1).T = ELECTRON.temperature*1e3;
%----------------Deuterium----------------%
Ps(2).Name = 'Deuterium';
Ps(2).q = 1;
Ps(2).m = 2*u;
Ps(2).n0 = IONS_1.density;
Ps(2).T = IONS_1.temperature*1e3;
%----------------Tritium----------------%
Ps(3).Name = 'Tritium';
Ps(3).q = 1;
Ps(3).m = 3*u;
Ps(3).n0 = IONS_2.density;
Ps(3).T = IONS_2.temperature*1e3;
%----------------Helium----------------%
Ps(4).Name = 'Cold Helium';
Ps(4).q = 2;
Ps(4).m = 4*u;
Ps(4).n0 = IONS_3.density;
Ps(4).T = IONS_3.temperature*1e3;
%----------------Argon----------------%
Ps(5).Name = 'Argon';
Ps(5).q = 18;
Ps(5).m = 40*u;
Ps(5).n0 = IONS_4.density;
Ps(5).T = IONS_4.temperature*1e3;
%----------------NBI Deuterium----------------%
Ps(6).Name = 'NBI Deuterium';
Ps(6).q = 1;
Ps(6).m = 2*u;
Ps(6).n0 = IONS_5.density;
Ps(6).T = IONS_5.temperature*1e3;
%----------------Fast Alpha----------------%
% T
Ps(7).Name = 'Fast Alpha';
Ps(7).q = 2;
Ps(7).m = 4*u;
Ps(7).n0 = IONS_6.density;
Ps(7).T = IONS_6.temperature*1e3;
% Correction of CFETR NBI energy
Ps(6).T(176:end) = Ps(6).T(175);
% Neutralize
Qe = abs(Ps(1).q)*Ps(1).n0;
Qi = 0;
for k = 2:numel(Ps)
    Qi = Qi + Ps(k).q*Ps(k).n0;
end
errormax = 1e-5;
itertime = 0;
OK = all(abs(Qe - Qi) < errormax*Qe, 'all');
if ~OK && itertime < 1000
    itertime = itertime + 1;
    QeQi = Qe./Qi;
    Qi = 0;
    for k = 2:numel(Ps)
        Ps(k).n0 = Ps(k).n0.*QeQi;
        Qi = Qi + Ps(k).q*Ps(k).n0;
    end
    OK = all(abs(Qe - Qi) < errormax*Qe, 'all');
end
fprintf('Iter time = %d\n', itertime);

% Load gfile
G = loadGfile('gfile_Steady');
save([FolderName, '/CFETR_Neut_Steady.mat'], "c", "e", "me", "u", "epsilon_0", "rho", "Ps");




F = figure;
hold on;
plot(rho, Ps(1).n0/1e19, 'LineWidth', 1, 'DisplayName', 'Electron');
plot(rho, Ps(2).n0/1e19, 'LineWidth', 1, 'DisplayName', 'Deuterium');
plot(rho, Ps(3).n0/1e19, 'LineWidth', 1, 'DisplayName', 'Tritium');
xlabel('$\rho$', 'Interpreter', 'latex');
ylabel('$n_0 / 10^{19}m^{-3}$', 'Interpreter', 'latex');
legend('Location', 'southwest', 'Interpreter', 'latex');
title('Density profile of CFETR steady-state senerio', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
savefig(F, [FolderName, '/Steady_Density.fig']);
saveas(F, [FolderName, '/Steady_Density.png']);

F = figure;
hold on;
plot(rho, Ps(1).T/1e3, 'LineWidth', 1, 'DisplayName', 'Electron');
plot(rho, Ps(1).T/1e3, 'LineWidth', 1, 'DisplayName', 'Deuterium');
plot(rho, Ps(1).T/1e3, 'LineWidth', 1, 'DisplayName', 'Tritium');
xlabel('$\rho$', 'Interpreter', 'latex');
ylabel('$T / keV$', 'Interpreter', 'latex');
legend('Location', 'southwest', 'Interpreter', 'latex');
title('Temperature profile of CFETR steady-state senerio', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
savefig(F, [FolderName, '/Steady_Temperature.fig']);
saveas(F, [FolderName, '/Steady_Temperature.png']);


F = figure;
hold on;
imagesc(G.R, G.Z, G.Brz);
plot(G.Rbound, G.Zbound, 'r-', 'LineWidth', 1, 'DisplayName', 'LCFS');
legend;
axis equal;
set(gca, 'YDir', 'Normal');
xlabel('$R/m$', 'Interpreter', 'latex');
ylabel('$Z/m$', 'Interpreter', 'latex');
C = colorbar;
C.Label.String = '$B/T$';
C.Label.Interpreter = 'latex';
title('B field of CFETR steady state henerio', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
savefig(F, [FolderName, '/B_Steady.fig']);
saveas(F, [FolderName, '/B_Steady.png']);