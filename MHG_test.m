cfg.vol=uint8(ones(158,102,66)); % size in grid units (length,width,height)
%cfg.vol(:,:,1)=0; % pad a layer of 0s to get diffuse reflectance

cfg.tstart = 0;
cfg.tend = 5e-9;
cfg.tstep=5e-9;

cfg.unitinmm=0.5;%this statement specifies that each grid-edge 0.05mm

cfg.nphoton=1e7;%close ae7;
cfg.issrcfrom0=1;

cfg.gpuid=1;    
cfg.autopilot=1;
 
% save positions & directions of escaping photons
cfg.issaveexit=1;

cfg.issaveref=1;

% [mua(1/mm), mus(1/mm), g, n]
prop1=[0.00  0.0     1.0     1.0;   % first row: ambient medium by default
       0.04  0.5     0.9     1.4];    % media optical properties
cfg.prop = prop1;

%%
cfg.srcpos = [39 51 1];

cfg.srcdir=[0 0 1];   % Direction - positive z-direction
% cfg.srctype = 'gaussian';
% cfg.srcparam1 = zeros(1,4);
% cfg.srcparam1(1) = 5.5;

cfg.detpos=[79 54 1 2; 79 47 1 2; 84 51 1 2; 73 51 1 2; 79 43 1 2; 88 51 1 2; 95 51 1 2; 105 51 1 2; 115 51 1 2; 130 51 1 2];       %grid units!
cfg.detpos(:,1) = cfg.detpos(:,1)-40;
detpos = cfg.detpos(:,1:3);

separation=getdistance(cfg.srcpos,detpos)*cfg.unitinmm;
% dimless_sep=separation*prop1(2,2);

%%
path1 =addpath(genpath('/home/laninil/Documents/MonteCarlo/mcx-master_oneFile'));
path2 =addpath('/home/laninil/Documents/MonteCarlo/mcx-master_oneFile/utils');
path3= addpath('/home/laninil/Documents/MonteCarlo/mcx-master_oneFile/mcxlab');

cfg.gamma = 1.3;        %CONDITION: gamma<1+g

alpha = (cfg.gamma - 3/5)/(cfg.gamma * prop1(2,3) - prop1(2,3)*prop1(2,3) + 2/5);       %retrieve alpha from given value of gamma and g
cfg.prop(2,2) = prop1(2,2)/(1-alpha*prop1(2,3));       %MC wants mu_s=mu_s'/(1-g1), g1=alpha*g

[fluence_MHG,detpt_MHG]=mcxlab(cfg);
drefmc_MHG = mcxcwdref(detpt_MHG, cfg);     % this is the reflectance I get

figure()
semilogy(separation, drefmc_MHG, 'DisplayName', strcat('MHG, \gamma=', num2str(cfg.gamma)), 'LineWidth', 1.5);     
hold on

% %this part is to compare with classic HG MC
% clear path1 path2 path3
% cfg = rmfield(cfg,'gamma');
% path1 =addpath(genpath('/home/laninil/Documents/MonteCarlo/mcx-master_original'));
% path2 =addpath('/home/laninil/Documents/MonteCarlo/mcx-master_original/utils');
% path4= addpath('/home/laninil/Documents/MonteCarlo/mcx-master_original/mcxlab');
% cfg.prop = prop1;
% cfg.prop(2,2) = prop1(2,2)/(1-prop1(2,3));
% [fluence_HG2,detpt_HG2]=mcxlab(cfg);
% drefmc_HG2 = mcxcwdref(detpt_HG2, cfg);% this is the reflectance I get
% semilogy(separation, drefmc_HG2, 'DisplayName', 'HG', 'LineWidth', 1.5); %-log(drefmc_HG(end))+log(drefmc_MHG(end))

legend()
xlabel('Separation [mm]')
ylabel('Reflectance')
title(strcat('\mu_a=',num2str(cfg.prop(2,1)),', \mu_s=',num2str(prop1(2,2)), ', g=', num2str(cfg.prop(2,3)), ', n=1.4'))


