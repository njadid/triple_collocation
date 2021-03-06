clear all
close all
clc
addpath('tools');

% dimensions of problem
Nt = 1e5;
Ns = 7;
Nb = 10;

% set varibale along each dimension
S = linspace(0,sqrt(0.5),Ns);
B = linspace(2,50,Nb);

% set truth
T = randn(Nt,1);

% loop through experiments
for s = 1:Ns

 % create measurements 
 X = T + randn(Nt,1)*S(s);
 Y = T + randn(Nt,1)*S(s);
 Z = T + randn(Nt,1)*S(s);

 % calculate continuous linear TC stats
 [LE(s,1,1),LE(s,2,1),LE(s,3,1),LI(s,1,1),LI(s,2,1),LI(s,3,1)] = triple_collocation(X,Y,Z);

 % calculate linear continuous truth
 LE(s,1,2) = cov(X-T)/cov(X);
 LE(s,2,2) = cov(Y-T)/cov(Y);
 LE(s,3,2) = cov(Z-T)/cov(Z);
 cc = corrcoef(X,T); LI(s,1,2) = cc(2);
 cc = corrcoef(Y,T); LI(s,2,2) = cc(2);
 cc = corrcoef(Z,T); LI(s,3,2) = cc(2);

 % loop through resolutions
 for b = 1:Nb

  % create bins at resolution
  Bt = linspace(min(T)-1e-6,max(T)+1e-6,B(b));
  Bx = linspace(min(X)-1e-6,max(X)+1e-6,B(b));
  By = linspace(min(Y)-1e-6,max(Y)+1e-6,B(b));
  Bz = linspace(min(Z)-1e-6,max(Z)+1e-6,B(b));

  % calculate nonlinear TC stats
  [Ixyz,Ixy,Ixz,Iyz,Hx,Hy,Hz] = mutual_info_3(X,Y,Z,Bx,By,Bz);

  % bound on total information
  NI(s,1,1,b) = (Ixy+Ixz-Ixyz)/Hx; 
  NI(s,2,1,b) = (Ixy+Iyz-Ixyz)/Hy; 
  NI(s,3,1,b) = (Ixz+Iyz-Ixyz)/Hz; 

  % bound on total error
  NE(s,1,1,b) = 1-(Ixy+Ixz-Ixyz)/Hx;
  NE(s,2,1,b) = 1-(Ixy+Iyz-Ixyz)/Hy;
  NE(s,3,1,b) = 1-(Ixz+Iyz-Ixyz)/Hz;

  % bound on missing information
  NM(s,1,1,b) = (Iyz-Ixyz)/Hx;
  NM(s,2,1,b) = (Ixz-Ixyz)/Hy;
  NM(s,3,1,b) = (Ixy-Ixyz)/Hz;

  % calculate true stats
  [Ixt,Hx,Ht] = mutual_info(X,T,Bx,Bt);
  NI(s,1,2,b) = Ixt/Hx;
  NE(s,1,2,b) = 1-Ixt/Hx;
  NM(s,1,2,b) = (Ht-Ixt)/Hx;

  [Ixt,Hx,Ht] = mutual_info(Y,T,By,Bt);
  NI(s,2,2,b) = Ixt/Hx;
  NE(s,2,2,b) = 1-Ixt/Hx;
  NM(s,2,2,b) = (Ht-Ixt)/Hx;

  [Ixt,Hx,Ht] = mutual_info(Z,T,Bz,Bt);
  NI(s,3,2,b) = Ixt/Hx;
  NE(s,3,2,b) = 1-Ixt/Hx;
  NM(s,3,2,b) = (Ht-Ixt)/Hx;

  % screen report
  [s/Ns,b/Nb]

 end % bin resolution
end % error variance

%% --------- PLOT RESULTS -----------

% grab colors
figure(1); close(1); figure(1);
h = plot(randn(10));
for i = 1:10
 colors(i,:) = h(i).Color;
end
close(1);

% error plots
figure(2); close(2); fig=figure(2);
set(gcf,'color','w');

%subplot(1,3,1)
h1 = plot(squeeze(NE(:,1,2,:)),squeeze(NE(:,1,1,:)),'-o','linewidth',1,'color',colors(1,:)); hold on;
h2 = plot(squeeze(NI(:,1,2,:)),squeeze(NI(:,1,1,:)),'-o','linewidth',1,'color',colors(2,:)); hold on;
h3 = plot(squeeze(NM(:,1,2,:)),squeeze(NM(:,1,1,:)),'-o','linewidth',1,'color',colors(3,:)); hold on;
plot([0,1],[0,1],'k--')
grid on; 
xlabel('true statistic','fontsize',18);
ylabel('estimated statistic','fontsize',18);
title('nonparametric TC','fontsize',16);
legend([h1(1),h2(2),h3(3)],'total error','total info','missing info','location','nw');
axis([0,1,0,1]);

fname = 'figures/Figure3_LinearSyntheticResponses';
img = getframe(gcf);
imwrite(img.cdata, [fname, '.png']);

