% TestConstants
% Kaitlin Dennison
% Stanford University 
% Winter 2019

%% File System
currDir = pwd;
addpath(genpath(currDir));
mainFldr = 'TestScripts/';
astModelFldr = 'AsteroidModels/';
ftDBloc = 'ftDBtest.mat'; 
    % .mat file containing the feature locations with the variable name 
        % ftDB: [nx3] [x y z] ACAF frame
saveWorkspace = 'wksp.mat';

%% Solar System
mu_sun = 1.3271244004193938E11; % Grav Param of Sun [km^3/s^2]
AU = 149597870.7; % AU conversion [km/AU]
G = 6.67259*10^-20; % Gravitational Constant
Reqec = rotEQUtoECL();

%% Asteroid 
ast.filename = 'eros3mill'; % High Res Model %CHANGE
ast.filenameLR = 'eros200700'; % Low Res Model %CHANGE
ast.m = 6.687E15; % mass [kg]
ast.mu = G*ast.m;
ast.alb = 0.8;  % albedo
% Orbital Elements (JPL HORIZONS)
ast.JD_epoch = 2451170.5;   % JD epoch [days]
% 1998 Dec 23 00:00:00 UTC
ast.e = 0.2228858603247133;                        % eccentricity
ast.i = deg2rad(10.83015266864554);                % inclination [rad]
ast.a = 1.458260038106518*AU;                      % semi-major axis [km]
ast.w = deg2rad(178.6132327246327);                % arg or per [rad]
ast.Om = deg2rad(304.4308844737856);               % RAAN [rad]
ast.M_0 = deg2rad(208.1235381788443);              % mean anomaly [rad]
ast.n = deg2rad(0.5596952381222570)/(24*60*60);    % mean motion [rad/s]
ast.T = 2*pi/ast.n;                                % period [s/rev]
% Rotation Parameters (IAU Report) epoch: J2000
ast.alp = 11.35;                                   % ascention [deg]
ast.del = 17.22;                                   % declination [deg]
ast.W_0 = 326.07;                                  % prime meridian [deg]
ast.W_d = 1639.38864745;                           % rotation rate [deg]

%% Spacecraft Options
% Sat 1: ANS
JD_0 = datenum(2019,9,4,0,0,0)+1721058.5;  % JD epoch [days]
scANS = spacecraft(JD_0,0.01,deg2rad(80),35,0,deg2rad(220),1.5,ast.mu);
% Sat 2: NEAR Shoemaker 
scNEAR = spacecraft(2451170.5,0.65,deg2rad(-30),200,pi,0.8,0,ast.mu);
    % JD 1998 Dec 23 00:00:00 UTC

%% Simulation 
% Set 1: one full satellite orbit
JD_0 = datenum(2019,9,4,0,0,0)+1721058.5; % start time [JD]
dur = scANS.T;                                       % duration of sim [s]
pts = 20;                                          % number of ims to take
JDspan = linspace(JD_0,JD_0+dur/(60*60*24),pts);   % time span [JD]

% Set 2: Eros orbit about Sun, random point spread
%{
    JD_0 = datenum(2019,9,4,0,0,0)+1721058.5;        % start time [JD]
    dur = ast.T./86400;                              % duration of sim [JD]
    pts = 1000;                                      % number of ims to take
    rPts = sort(rand(1,pts-2));                      % randomly choose points
    JDspan = [JD_0, rPts.*dur + JD_0, JD_0 + dur];   % time span [JD]
%}

%% Camera Options
% Set 1: NEAR Shoemaker
% https://nssdc.gsfc.nasa.gov/nmc/experimentDisplay.do?id=1996-008A-01
camNEAR = camera(168,[244 537],[27 16]);
% Set 2: Point Grey Camera
camPtGry = camera(17,[1200 1920],[5.86 5.86]);
% Set 3: OSIRIS-REx
camOSIRIS = camera(7.6,[1944 2592],[2.2 2.2]);
% Set 4: Nikon D810 (extremely high-res)
% https://www.ephotozine.com/article/nikon-d810-digital-slr-expert-review-25758
camNikon = camera(100,[4912 7360],[4.9 4.9]);

%% UKF Params 
dr = 50; % Bounding radius for potential matches
Mah = [dr dr].^(2);
% Mah = diag([1 1 0.5].^(-2)); 
    % Make this bigger if things aren't correlating. Mahalanobis distance
    % is essentially a covariance for position. In fact, you might try
    % using the 3x3 covariance associated with the x,y,z ACI position of
    % the indv feature as generated by the UKF to get a better metric
measCov = eye(2).*dr;
Pdefault = [0.2 0 0 0.2 0 0.2].^2;
dr = 50; % Bounding radius for potential matches
Mah = [dr dr].^(2);
sigM = 0.75;
tolM = 5^2;
maxR = 1000;

%% Database Setup 
maxDBpts = 1500;                                  % max # of points in DB
timePen = 20;                                    % time penalty for point retention
numTop = 100;
rslvDist =@(r) ((r/(1e-6)-camParams(1))*norm(camParams(4:5))/camParams(1))*(1e-6); % the camera's resolvable distance
