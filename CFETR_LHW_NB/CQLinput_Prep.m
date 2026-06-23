% CQLinput_Prep
format long;
close all;
clear;
clc;

%% Load CFETR parameters
load('./Profile_data/CFETR_Neut_Hybrid.mat');
G = loadGfile('Gfile_Hybrid');
Psh = Ps(end-1:end);
Ph = Ps(end-1:end);
Ps = Ps(1:end-2);
Ph(1).u0 = sqrt(2*1e6*e/Ph(1).m);
Ph(2).u0 = sqrt(2*3.5e6*e/Ph(2).m);
vc = Vc(Ps);
for k = 1:numel(Ph)
    Ph(k).uc = vc;
end
R = 7.2;
a = 2.2;
% Non-Rel fast electrons
N_para = -2.04;
Ph(3).Name = Ps(1).Name;
Ph(3).q = Ps(1).q;
Ph(3).m = Ps(1).m;
Ph(3).n0 = 5e-4*Ps(1).n0;
Ph(3).T = repmat(0.5*Ph(3).m*(c/N_para).^2, size(rho));
Ph(3).u0 = c;
Ph(3).uc = c./linspace(1.5, 2.25, numel(rho));


%% Check if the zero orbit width limit holds
rhoL2a_NB = Ph(1).m*Ph(1).u0/Ph(1).q/e./G.Bprz/a;
% rhoL2a_NB(~G.inLCFS) = 0;
rhoL2a_alpha = Ph(2).m*Ph(2).u0/Ph(2).q/e./G.Bprz/a;
% rhoL2a_alpha(~G.inLCFS) = 0;

% F = figure;
% ScreenSize = get(0, 'ScreenSize');
% FigSize = [ScreenSize([1, 2]), ScreenSize([3, 4])/2];
% set(F, 'OuterPosition', ScreenSize);
% subplot(1, 2, 1);
% hold on;
% imagesc(G.R, G.Z, rhoL2a_NB);
% axis equal;
% set(gca, 'YDir', 'Normal');
% colormap(jet(20));
% colorbar;
% clim([0, 1]);
% plot(G.Rbound, G.Zbound, 'r-', 'LineWidth', 2);
% xlabel('$R/m$', 'Interpreter', 'latex');
% ylabel('$Z/m$', 'Interpreter', 'latex');
% title('$\rho_{NB} / a$', 'Interpreter', 'latex');
% set(gca, 'FontSize', 20);
% subplot(1, 2, 2);
% hold on;
% imagesc(G.R, G.Z, rhoL2a_alpha);
% axis equal;
% set(gca, 'YDir', 'Normal');
% colormap(jet(20));
% colorbar;
% clim([0, 1]);
% plot(G.Rbound, G.Zbound, 'r-', 'LineWidth', 2);
% xlabel('$R/m$', 'Interpreter', 'latex');
% ylabel('$Z/m$', 'Interpreter', 'latex');
% title('$\rho_{\alpha} / a$', 'Interpreter', 'latex');
% set(gca, 'FontSize', 20);
% % savefig(F, 'Zero_Orbit_Width_Limit.fig');
% saveas(F, 'Zero_Orbit_Width_Limit.png');


%% Calculate the slowing-down time
n0scale = [0.4, 0.7, 1.0, 1.2].';
npscale = [0.5, 0.75, 1.0, 1.1].';
nscale = nan(numel(n0scale), numel(rho));
for k = 1:numel(n0scale)
    nscale(k, :) = [linspace(n0scale(k), npscale(k), 181), repmat(npscale(k), 1, 20)];
end
T0scale = [0.45, 0.75, 1.0, 1.25].';
Tpscale = [0.6, 0.8, 1.0, 1.2].';
Tscale = nan(numel(n0scale), numel(rho));
for k = 1:numel(T0scale)
    Tscale(k, :) = [linspace(T0scale(k), Tpscale(k), 181), repmat(Tpscale(k), 1, 20)];
end
% The maximum density
Ps0 = Ps;
for k = 1:numel(Ps0)
    Ps0(k).n0 = Ps(k).n0.*nscale(end, :);
end
% Velocity range and tau array for 'fast' particles
for k = 1:numel(Ph)
    Ph(k).ve = 0.3*Ph(k).u0;
    Ph(k).v = linspace(Ph(k).ve, Ph(k).u0, 51).';
    Ph(k).mus = nan(numel(Ph(k).v), numel(rho), numel(T0scale));
    Ph(k).mupar = nan(numel(Ph(k).v), numel(rho), numel(T0scale));
    Ph(k).muper = nan(numel(Ph(k).v), numel(rho), numel(T0scale));
    Ph(k).muepsi = nan(numel(Ph(k).v), numel(rho), numel(T0scale));
end
% Calculate the typical time
for j = 1:numel(T0scale)
    % Set the background temperature
    for k = 1:numel(Ps0)
        Ps0(k).T = Ps(k).T.*Tscale(j, :);
    end
    % Scan the typical slowing-down time
    for k = 1:numel(Ph)
        [mu_tmp, mupar_tmp, muper_tmp, muepsi_tmp] = MuColl(Ph(k), Ps0, Ph(k).v);
        Ph(k).mus(:, :, j) = mu_tmp;
        Ph(k).mupar(:, :, j) = mupar_tmp;
        Ph(k).muper(:, :, j) = muper_tmp;
        Ph(k).muepsi(:, :, j) = muepsi_tmp;
    end
end
% Calculate the bounce time
rhor = rho.*a;
qspilne = spline(G.rho, G.q, rho);
Lpara = 2*pi*sqrt((R*qspilne).^2 + a^2);
for k = 1:numel(Ph)
    Ph(k).taub = Lpara./(0.1*Ph(k).u0);
end
% % Plot the collision time
% for k = 1:numel(Ph)
%     F = figure;
%     set(F, 'OuterPosition', get(0, 'ScreenSize'));
%     x = repmat(rho, size(Ph(k).v));
%     z = repmat(Ph(k).v/Ph(k).u0, size(rho));
%     for j = 1:numel(T0scale)
%         % ------------------- Plot tau_s ------------------- %
%         subplot(numel(T0scale), 4, 4*(j-1) + 1);
%         hold on;
%         y = 1./Ph(k).mus(:, :, j);
%         p = pcolor(x, y, z);
%         colormap(jet(20));
%         p.DisplayName = '$\tau_s$';
%         set(p, 'EdgeColor', 'none');
%         C = colorbar;
%         C.Label.String = '$v/v_0$';
%         C.Label.Interpreter = 'latex';
%         ax = gca;
%         ax.YScale = 'log';
%         if k < 3
%             plot(rho, Ph(k).taub, 'k-', 'LineWidth', 1.5, 'DisplayName', '$\tau_b$');
%         end
%         xlabel('$\rho$', 'Interpreter', 'latex');
%         ylabel('$\tau_s / s$', 'Interpreter', 'latex');
%         if k ~= 3
%             yticks(10.^(-5:5));
%         end
%         title(['$\tau_s$ at $<T> = ', num2str((T0scale(j) + Tpscale(j))/2, '%.2f'), '$'], 'Interpreter', 'latex');
%         set(gca, 'FontSize', 13);
%         % ------------------- Plot tau_par ------------------- %
%         subplot(numel(T0scale), 4, 4*(j-1) + 2);
%         hold on;
%         y = 1./Ph(k).mupar(:, :, j);
%         p = pcolor(x, y, z);
%         colormap(jet(20));
%         p.DisplayName = '$\tau_{\parallel}$';
%         set(p, 'EdgeColor', 'none');
%         C = colorbar;
%         C.Label.String = '$v/v_0$';
%         C.Label.Interpreter = 'latex';
%         ax = gca;
%         ax.YScale = 'log';
%         plot(rho, Ph(k).taub, 'k-', 'LineWidth', 1.5, 'DisplayName', '$\tau_b$');
%         xlabel('$\rho$', 'Interpreter', 'latex');
%         ylabel('$\tau_{\parallel} / s$', 'Interpreter', 'latex');
%         yticks(10.^(-5:5));
%         title(['$\tau_{\parallel}$ at $<T> = ', num2str((T0scale(j) + Tpscale(j))/2, '%.2f'), '$'], 'Interpreter', 'latex');
%         set(gca, 'FontSize', 13);
%         % ------------------- Plot tau_per ------------------- %
%         subplot(numel(T0scale), 4, 4*(j-1) + 3);
%         hold on;
%         y = 1./Ph(k).muper(:, :, j);
%         p = pcolor(x, y, z);
%         colormap(jet(20));
%         p.DisplayName = '$\tau_{\perp}$';
%         set(p, 'EdgeColor', 'none');
%         C = colorbar;
%         C.Label.String = '$v/v_0$';
%         C.Label.Interpreter = 'latex';
%         ax = gca;
%         ax.YScale = 'log';
%         if k < 3
%             plot(rho, Ph(k).taub, 'k-', 'LineWidth', 1.5, 'DisplayName', '$\tau_b$');
%         end
%         xlabel('$\rho$', 'Interpreter', 'latex');
%         ylabel('$\tau_{\perp} / s$', 'Interpreter', 'latex');
%         if k ~= 3
%             yticks(10.^(-5:5));
%         end
%         title(['$\tau_{\perp}$ at $<T> = ', num2str((T0scale(j) + Tpscale(j))/2, '%.2f'), '$'], 'Interpreter', 'latex');
%         set(gca, 'FontSize', 13);
%         % ------------------- Plot tau_epsi ------------------- %
%         subplot(numel(T0scale), 4, 4*(j-1) + 4);
%         hold on;
%         y = 1./Ph(k).muepsi(:, :, j);
%         p = pcolor(x, y, z);
%         colormap(jet(20));
%         p.DisplayName = '$\tau_{\varepsilon}$';
%         set(p, 'EdgeColor', 'none');
%         C = colorbar;
%         C.Label.String = '$v/v_0$';
%         C.Label.Interpreter = 'latex';
%         ax = gca;
%         ax.YScale = 'log';
%         plot(rho, Ph(k).taub, 'k-', 'LineWidth', 1.5, 'DisplayName', '$\tau_b$')
%         xlabel('$\rho$', 'Interpreter', 'latex');
%         ylabel('$\tau_{\varepsilon} / s$', 'Interpreter', 'latex');
%         yticks(10.^(-5:5));
%         title(['$\tau_{\varepsilon}$ at $<T> = ', num2str((T0scale(j) + Tpscale(j))/2, '%.2f'), '$'], 'Interpreter', 'latex');
%         set(gca, 'FontSize', 13);
%     end
%     sgtitle(['Typical slowing-down time of ', Ph(k).Name], 'Interpreter', 'latex', 'FontSize', 20);
%     % savefig(F, ['Slowing-down Time of ', Ph(k).Name, '.fig']);
%     saveas(F, ['Slowing-down Time of ', Ph(k).Name, '.png']);
% end

% Calculate the full slowing-down time
% The minimum density
Ps1 = [Ps, Psh];
for k = 1:numel(Ps1)-2
    Ps1(k).n0 = Ps(k).n0.*nscale(end, :);
end
% Set the taufull array
for k = 1:numel(Ph)
    Ph(k).taufull = nan(numel(T0scale), numel(rho));
end
% Calculate the typical time
E0fastion = [1e6, 3.5e6];
for j = 1:numel(T0scale)
    % Set the background temperature
    for k = 1:numel(Ps1)-2
        Ps1(k).T = Ps(k).T.*Tscale(j, :);
    end
    % Scan the typical slowing-down time
    for k = 1:numel(Ph)-1
        Ph(k).taufull(j, :) = Taufull(Ps1, numel(Ps) + k, E0fastion(k));
    end
end

for k = 1:2
    F = figure;
    plot(rho, Ph(1).taufull, 'LineWidth', 2, 'DisplayName', Ph(1).Name);
    xlabel('$\rho$', 'Interpreter', 'latex');
    ylabel('$\tau_{full} / s$', 'Interpreter', 'latex');
    title(['Full Slowing-down Time ', ...
        '$\tau_s = \frac{\tau_s^e}{3}\ln\left[1 + \left( \frac{E_0}{E_c} \right)^{\frac{3}{2}}\right]$', ...
        ' of ', Ph(k).Name], 'Interpreter', 'latex');
    set(gca, 'FontSize', 13);
    % savefig(F, ['Full Slowing-down Time of ', Ph(k).Name, '.fig']);
    saveas(F, ['Full Slowing-down Time of ', Ph(k).Name, '.png']);
end
figure;
plot(rho, Ph(2).taufull, 'LineWidth', 2, 'DisplayName', Ph(1).Name);

%% Set the 'velocity' space mesh
% The electron distribution
Tscalemax = max(Tscale, [], 'all');
Tscalemin = min(Tscale, [], 'all');
Tscale_extre = [linspace(Tscalemax, Tscalemin, 181), repmat(Tscalemin, 1, 20)];
for k = 1:numel(Ps0)
    Ps0(k).T = Ps(k).T.*Tscale_extre;
end
[p, fp3d, fpmod, v, E] = RelMaxDist(Ps0(1), 'pmN', 3);
% The resonant condition
Nparmin = 1.44;
Nparmax = 3.04;


vparmin = c/Nparmin;
pparmin = vparmin./sqrt(1 - Nparmin.^-2);
vparmax = c/Nparmax;
pparmax = vparmax./sqrt(1 - Nparmax.^-2);
F = figure;
hold on;
plot(p*c, fpmod(:, 1));
plot(p*c, fpmod(:, 190));
xline(pparmin);
xline(pparmax);
xline(Ph(1).u0, '--');
xline(Ph(2).u0, '--');
xlabel('$v$ or $\frac{p_e}{m_{e0}c}$', 'Interpreter', 'latex')


enorme = ceil(max(E)*me*c^2/e/1e3)
enormi = ceil(0.5*max(Ph(1).u0, Ph(2).u0)^2 * Ph(1).m / e/1e3) + 50

jx = ceil(numel(p*c)/10)*10
xmax = max(p*c, [], 'all')
xlwr = sqrt(2*enormi*1e3*e/Ph(1).m)/xmax
xpctlwr = 0.3
jxion = xpctlwr*jx
xmdl = min(pparmin, pparmax)/xmax
xpctmdl = (1 - xpctlwr)/(1 - xlwr).*(xmdl - xlwr)
xpctmdl = round(xpctmdl*jx)/jx


vnorm = sqrt(2*1800*1e3*e./Ph(1).m)
enorme = 0.5*me*vnorm^2/e/1e3
enormi = max(Ps(2).T)/1e3
xmax = vnorm
xlwr = sqrt(2*Ps(5).T(181)*e./Ps(5).m)/xmax
xpctlwr = xlwr
xmdl = sqrt(2*enormi*1e3*e/Ph(1).m)/xmax
xpctmdl = xmdl



% For fast ion loss at v = 0
enloss_NB = 0.5*Ph(1).m*(mean(p([2, 3]))*c)^2 / e/1e3
enloss_alpha = 0.5*Ph(2).m*(mean(p([2, 3]))*c)^2 / e/1e3

%% Print the rho, density, temperature, Zeff and rotation profile
% Physical Constants
c = 299792458;
me = 9.1093829e-31;
e = 1.602176565e-19;
u = 1.660538921e-27;
epsilon_0 = 8.854187817e-12;
% Load the CFETR profile
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

Neutralize = true;
if Neutralize
    Qe = abs(Ps(1).q)*Ps(1).n0;
    Qi = zeros(size(Qe));
    for k = 2:numel(Ps)
        Qi = Qi + Ps(k).q*Ps(k).n0;
    end
    errormax = 1e-5;
    itertime = 0;
    OK = all(abs(Qe - Qi) < errormax*Qe, 'all');
    if ~OK && itertime < 1000
        itertime = itertime + 1;
        QeQi = Qe./Qi;
        Qi = zeros(size(Qe));
        for k = 2:numel(Ps)
            Ps(k).n0 = Ps(k).n0.*QeQi;
            Qi = Qi + Ps(k).q*Ps(k).n0;
        end
        OK = all(abs(Qe - Qi) < errormax*Qe, 'all');
    end
    fprintf('Iter time = %d\n', itertime);
end

% Print the ryain
% fprintf('------------------------------ rho ------------------------------\n\n');
fprintf(' ryain =\t');
for j = 1:numel(rho)
    if mod(j, 5) == 0
        fprintf('\n\t\t');
    end
    fprintf('%.4f,  ', rho(j));
end
fprintf('\n\n\n\n\n');

%Print density
% fprintf('------------------------------ density ------------------------------\n\n');
lind = [1, 6, 7, 2, 3, 4, 5, 1];
for l = 1:numel(lind)
    fprintf('enein(1,%d) = ', l);
    for j = 1:numel(rho)
        if mod(j, 4) == 0
            fprintf('\n\t');
        end
        % fprintf('%.11e  ', Ps(lind(l)).n0(j)/1e6);
        fprintf('%s,  ', strrep(sprintf('%.11e', Ps(lind(l)).n0(j)/1e6), 'e', 'd'));
    end
    fprintf('\n');
end
fprintf('\n\n\n');

% Print temperature
% fprintf('------------------------------ temperature ------------------------------\n\n');
% The electron temperature
fprintf('tein = ');
for j = 1:numel(rho)
    if mod(j, 4) == 0
        fprintf('\n\t');
    end
    % fprintf('%.11e  ', Ps(1).T(j)/1e3);
    fprintf('%s,  ', strrep(sprintf('%.11e', Ps(1).T(j)/1e3), 'e', 'd'));
end
fprintf('\n\n');
% Print ion temperature
fprintf('tiin = ');
for j = 1:numel(rho)
    if mod(j, 4) == 0
        fprintf('\n\t');
    end
    % fprintf('%.11e  ', Ps(2).T(j)/1e3)
    fprintf('%s,  ', strrep(sprintf('%.11e', Ps(2).T(j)/1e3), 'e', 'd'));
end
fprintf('\n\n');
fprintf('\n\n\n');

% Print zeff profile
% fprintf('------------------------------ temperature ------------------------------\n\n');
Zeff_ReCalc = true;
if Zeff_ReCalc
    Zeff = zeros(size(rho));
    for k = 2:numel(Ps)
        Zeff = Zeff + Ps(k).q.^2.*Ps(k).n0./Ps(1).n0;
    end
end
fprintf(' zeffin = ');
for j = 1:numel(rho)
    if mod(j, 4) == 0
        fprintf('\n\t');
    end
    fprintf('%.11f,  ', Zeff(j));
end
fprintf('\n\n');
fprintf('\n\n\n');


% Print the rotation profile
% fprintf('------------------------------ rotation ------------------------------\n\n');
vrot = omega*R0;
fprintf(' vphiplin = ');
for j = 1:numel(rho)
    if mod(j, 4) == 0
        fprintf('\n\t');
    end
    % fprintf('%.11e  ', vrot(j)*100);
    fprintf('%s,  ', strrep(sprintf('%.11e', vrot(j)*100), 'e', 'd'));
end
fprintf('\n\n');
fprintf('\n\n\n');


%% Determine the source width
% The principle is to limit the source within mesh [m-2, m+2]
% i.e. f(m .pm. 2) = exp(-Nexp^2) * f(m)
Nexp = 2;
Nexp2 = Nexp^2;
% -------------- Velocity width -------------- %
nxmesh1 = round(jx*xpctlwr);
xmesh1 = linspace(0, xlwr, nxmesh1 + 1);
nxmesh2 = round(jx*xpctmdl);
xmesh2= linspace(xlwr, xmdl, nxmesh2 + 1);
xmesh3= linspace(xmdl, 1, jx - nxmesh1 - nxmesh2);
xmesh = [xmesh1(1:end-1), xmesh2(1:end-1), xmesh3]*xmax;
% Ph(1)
[~, I1] = min(abs(Ph(1).u0 - xmesh));
dv1 = max(xmesh(max(I1 - 2, 1)) - xmesh(I1), xmesh(min(I1 + 2, numel(xmesh))) - xmesh(I1));
dE1 = Ph(1).m * (1/Nexp2) *dv1^2 / e / 1e3
[~, I2] = min(abs(Ph(2).u0 - xmesh));
dv2 = max(xmesh(max(I2 - 2, 1)) - xmesh(I2), xmesh(min(I2 + 2, numel(xmesh))) - xmesh(I2));
dE2 = Ph(2).m * (1/Nexp2) *dv2^2 / e / 1e3

% -------------- Pinch angle width -------------- %
iy = 240;
theta0 = pi/2;
dtheta = 2*pi/iy;
scm2z = (1/Nexp2) *max(abs(cos(theta0) - cos(theta0 - 2*dtheta)), abs(cos(theta0) - cos(theta0 + 2*dtheta)))^2

%% Determine the fusion alpha and NBI source in cm^-3/s
Salpha = Ps(2).n0.*Ps(3).n0.*DTsigmav(Ps(2).T);
taualpha = Taufull(Ps([1:5, 7]), 6, 3.5e6);
nalp = Salpha.*taualpha;

F = figure;
hold on;
plot(rho, Ps(7).n0);
plot(rho, nalp);

rya = 0.01:0.02:0.99;
Salpha_interp = spline(rho, Salpha, rya);

% Print the alpha birth rate profile
fprintf('------------------------------ Alpha Birth Rate ------------------------------\n\n');
for j = 1:numel(rya)
    if mod(j, 4) == 0
        fprintf('\n\t\t');
    end
    % fprintf('%.11e,  ', Salpha_interp(j)*1e-6);
    fprintf('%s,  ', strrep(sprintf('%.11e', Salpha_interp(j)*1e-6), 'e', 'd'));
end
fprintf('\n\n');
fprintf('\n\n\n');


tauNB = Taufull(Ps([1:5, 6]), 6, 1e6);
nNB = 0.2*ELECTRON.density;
SNB = nNB./tauNB;
SNB_interp = spline(rho, SNB, rya);
% Print the NB birth rate profile
fprintf('------------------------------ NB Birth Rate ------------------------------\n\n');
% for j = 1:numel(rya)
%     if mod(j, 4) == 0
%         fprintf('\n\t\t');
%     end
%     % fprintf('%.11e,  ', Salpha_interp(j)*1e-6);
%     fprintf('%s,  ', strrep(sprintf('%.11e', SNB_interp(j)*1e-6), 'e', 'd'));
% end
% fprintf('\n\n');
% fprintf('\n\n\n');

for j = 1:numel(rya)
    % fprintf('%.11e,  ', Salpha_interp(j)*1e-6);
    fprintf('asor(1, 1, %d) = %s\n', j, strrep(sprintf('%.11e', SNB_interp(j)*1e-6), 'e', 'd'));
end
fprintf('\n\n');
fprintf('\n\n\n');

for j = 1:numel(rya)
    % fprintf('%.11e,  ', Salpha_interp(j)*1e-6);
    fprintf('asorz(1, 1, %d) = %s\n', j, strrep(sprintf('%.11e', SNB_interp(j)*1e-6), 'e', 'd'));
end
fprintf('\n\n');
fprintf('\n\n\n');

%% Calculate harmonics
w = 2*pi*4.6e9;
kparmax = Nparmax*w/c;
kparmin = Nparmin*w/c;
kparmax_abs = abs(kparmax);
kparmin_abs = abs(kparmin);
Bmax = max(G.Brz(G.inLCFS));
Bmin = min(G.Brz(G.inLCFS));
wch = nan(numel(Ph), 2);
wstar = nan(numel(Ph), 2);
harm = nan(numel(Ph), 2);
for k = 1:numel(Ph)
    wch(k, 1) = abs(Ph(k).q)*e*Bmin/Ph(k).m;
    wch(k, 2) = abs(Ph(k).q)*e*Bmax/Ph(k).m;
    if strcmp(Ph(k).Name, 'Electron')
        wstar(k, 1) = w - kparmax_abs*max(v)*c;
        wstar(k, 2) = w + kparmax_abs*max(v)*c;
    else
        wstar(k, 1) = w - kparmax_abs*Ph(k).u0;
        wstar(k, 2) = w + kparmax_abs*Ph(k).u0;
    end
    if wstar(k, 1) < 0
        harm(k, 1) = wstar(k, 1)/wch(k, 1);
    else
        harm(k, 1) = wstar(k, 1)/wch(k, 2);
    end
    harm(k, 2) = wstar(k, 2)/wch(k, 1) - ceil(harm(k, 1)) + 1;
end
% Print
for k = 1:numel(Ph)
    fprintf([Ph(k).Name, ' harnomic :\t\t%.2f\t\t%.2f\n'], harm(k, 1), harm(k, 2));
end


%% Calculate NBI launch (frsetup)
Rtang = 6;
Redge = max(G.Rbound);
rpivot = Redge + 3
angleh = asin(Rtang/rpivot)*180/pi



%% Plot NB parameters
% F = figure;
% set(F, 'OuterPosition', get(0, 'ScreenSize'));
% subplot(2, 2, 1);
% plot(rho, nbcd_current_density_onetwo, 'LineWidth', 2);
% xlabel('$\rho$', 'Interpreter', 'latex');
% ylabel('$J_{NB} / A$', 'Interpreter', 'latex');
% title('Neutral Beam Current Density', 'Interpreter', 'latex');
% set(gca, 'FontSize', 13);
% subplot(2, 2, 2);
% yyaxis left
% plot(rho, IONS_5.density, 'LineWidth', 2, 'DisplayName', '$n_{NB}$');
% ylabel('$n_{NB} / m^{-3}$', 'Interpreter', 'latex');
% yyaxis right;
% plot(rho, IONS_5.temperature, 'LineWidth', 2, 'DisplayName', '$T_{NB}$');
% ylabel('$T_{NB} / keV$', 'Interpreter', 'latex');
% xlabel('$\rho$', 'Interpreter', 'latex');
% legend('Interpreter', 'latex', 'Location', 'best');
% title('NB Density and Temperature', 'Interpreter', 'latex');
% set(gca, 'FontSize', 13);
% subplot(2, 2, 3);
% hold on;
% plot(rho, powers_particle_flux_ONETWO.flow_beam, 'LineWidth', 2, 'DisplayName', 'ONETWO');
% plot(rho, powers_particle_flux_TGYRO.flow_beam, '--', 'LineWidth', 2, 'DisplayName', 'TGYRO');
% xlabel('$\rho$', 'Interpreter', 'latex');
% ylabel('$\Gamma_e / s^{-1}$', 'Interpreter', 'latex');
% legend('Interpreter', 'latex', 'Location', 'best');
% title('Electron Flux by Neutral Beam', 'Interpreter', 'latex');
% set(gca, 'FontSize', 13);
% subplot(2, 2, 4);
% yyaxis left;
% plot(rho, powers_particle_flux_ONETWO.qbeame, 'LineWidth', 2, 'DisplayName', '$Q_e$');
% ylabel('$Q_e / W\cdot m^-3$', 'Interpreter', 'latex');
% yyaxis right;
% plot(rho, powers_particle_flux_ONETWO.qbeami, 'LineWidth', 2, 'DisplayName', '$Q_i$');
% ylabel('$Q_i / W\cdot m^-3$', 'Interpreter', 'latex');
% xlabel('$\rho$', 'Interpreter', 'latex');
% legend('Interpreter', 'latex', 'Location', 'best');
% title('Heating Power Density by NB', 'Interpreter', 'latex');
% set(gca, 'FontSize', 13);
% % savefig(F, 'Hybrid_Secnario_NB_Data.fig');
% saveas(F, 'Hybrid_Secnario_NB_Data.png');

%% Calculate the neoclassical diffusion coefficients
r = sqrt((G.R - G.Raxis).^2 + (G.Z - G.Zaxis).^2);
r(r < 0.3) = 0.3;
frz = (G.Raxis./r).^1.5./(G.Brz.^2);
favgrho = Contour_avg(G.R, G.Z, G.rhorz, frz, rho).';
Afac = 0.5;
qrho = spline(G.rho, G.q, rho);
Ps0 = Ps;
for k = 1:2
    Ps0(5+k).n0 = Ph(k).n0;
end
for k = 1:numel(Ph) - 1
    Gammafi = zeros(size(rho));
    for l =  2:5
        Gammafi = Gammafi + Gamma12(Ps0(5+k), Ps0(l));
    end
    Ph(k).Gammafi = Gammafi;
    uc = Ph(k).uc./Ph(k).u0;
    Ph(k).mu2v_avg = (1/3./Ph(k).uc) ./ log(1 + uc.^-3) .* ...
        ( log((1 - uc + uc.^2)./((1 + uc).^2)) + 2*sqrt(3)*(atan((2 - uc)./uc./sqrt(3)) + pi/6) );
    Ph(k).Drr = Afac * Ph(k).Gammafi .* (qrho*Ph(k).m./Ph(k).q./e).^2 .* favgrho .* Ph(k).mu2v_avg;
end

LineStyle = {'-', '--'};
F = figure;
hold on;
for k = 1:2
    plot(rho, Ph(1).Drr, LineStyle{k}, 'LineWidth', 1.5, 'DisplayName', Ph(k).Name);
end
legend('Interpreter', 'latex', 'Location', 'best');
xlabel('$\rho$', 'Interpreter', 'latex');
ylabel('$D_{rr} / m^2/s$', 'Interpreter', 'latex');
title('Flux and Velocity-space Averaged $D_{rr}$', 'Interpreter', 'latex');
set(gca, 'FontSize', 13);
% savefig(F, 'Drr.fig');
saveas(F, 'Drr.png');

% Print the neoclassical diffusion coeffs
fprintf(' difin = ');
for j = 1:numel(rho)
    if mod(j, 4) == 0
        fprintf('\n\t');
    end
    fprintf('%s,  ', strrep(sprintf('%.11e', Ph(1).Drr(j)), 'e', 'd'));
end
fprintf('\n\n');
fprintf('\n\n\n');