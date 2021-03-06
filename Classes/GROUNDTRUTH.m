classdef GROUNDTRUTH
    % Ground truth for ANS simulations
    %{
    -----------------------------------------------------------------------
    DESCRIPTION:
        Creates an object to store all of the ground truth data and
        simulation parameters for the ANS project. 
    
        Nomenclature:
        - ACI: Asteroid-centered-inertial J2000 navigation frame
        - ast: asteroid
        - eul: Euler angles
        - HCI: heleo-centric-inertial ecliptic plane
        - sat: satellite
        - sc: spacecraft
        - SCI: solar-centered-inertial J2000 equatorial frame
    -----------------------------------------------------------------------
    REFERENCES:
        - Text
    -----------------------------------------------------------------------
    NOTES:
        - If you want to change the default feature detector properties,
          use the setProp function after constructing the ANSGT object
        - All images will be saved in the Images folder associated with
          each spacecraft: 
          [ansGT.dirCurrent,'\',ansGT.dirData,'\',ansGT.spacecraft{n}.name,'\Images']
    -----------------------------------------------------------------------
    AUTHOR: Kaitlin Dennison
    -----------------------------------------------------------------------
    COPYTRIGHT: 2019 SLAB Group
    -----------------------------------------------------------------------
    TIMESTAMPS:
        - 09-Jun-2019: creation (KD)
        - 13-Jun-2019: style changes (KD)
        - 14-Jun-2019: style updates, changed asteroid to its own class,
          added in new parameters at req of Rin and Tom (KD)
        - 17-Jun-2019: renamed to GROUNDTRUTH, added setProp method
    -----------------------------------------------------------------------
    %}
    
    properties (SetAccess = private)
        %% File System
        name                % str, name of test or simulation to add to any 
                            % files created by this instance
        dirCurrent = pwd    % str, current working directory
        dirAstModels = 'AsteroidModels' % str, directory with .tab files
                            % for the 3D models
        dirData = 'Data'    % str, directory to store all data
        %% Simulation Parameters
        asteroid            % astroid, ASTEROID object (defualt: Eros)
        nSpacecraft         % int, number of spacecraft
        spacecraft          % nSpacecraftx1 cell, spacecraft objects
        tEpoch              % double, Julian date of epoch (days)
        tInterval           % double, time interval between images (s)
        nImages             % int, number of images per spacecraft
        %% Ground Truth Data
        tJD                 % nImagesx1 double, Julian date of each image 
                            % (days) 
        stateGT             % nImagesx(nSpacecraftxN+M) double, ground 
                            % truth of state estimate, excludes landmarks
        meta                % nImagesx12xnSpacecraft double, meta data 
                            % necessary for image generation 
                                % [JD,rSatACI,rAstSCI,eul,Ldxn]
                                % eul = rotMtoEul(R)
        rotMatrices         % struct, all rotation matrices
        
    end
    
    methods
        function gt = GROUNDTRUTH(varargin)
            % GROUNDTRUTH constructor
            %{
            ---------------------------------------------------------------
            INPUT: gt = GROUNDTRUTH('option1',value1,...)
                Input parsing is supported with defaults. ansGT = ANSGT() 
                sets all properties to default values
                name:       str, name of test or simulation to add to any
                            files created
                            DEFAULT: date of initialization in 
                            DD-MMM-YYYY format
                asteroid:   asteroid object, see ASTEROID.m
                            DEFAULT: Eros (see constructor function below)
                nSpacecraft: int, number of spacecraft in the swarm. If a 
                            number is input for this, it will generate the 
                            spacecraft cell array with the default 
                            spacecraft object and camera
                            DEFAULT: 2
                camera:     camera, the camera you want to use to setup the
                            default spacecraft. (See CAMERA.M)
                            Options: PtGrey12, PtGrey17, OSIRIS, NEAR, NanoCam
                            DEFAULT: PtGrey12
                spacecraft: nSpacecraftx1 cell of spacecraft objects
                            (See SPACECRAFT.m)
                tEpoch:     double, Julian date of the start of the sim
                            DEFAULT: 4 Sept 2019 00:00
                tInterval:  double, time between images (s)
                            DEFAULT: 300 (5 min)
                nImages:    double, number of images taken over the sim
                            DEFAULT: 500
            ---------------------------------------------------------------
            OUTPUT:
                gt:         GROUNDTRUTH object, all simulation parameters
                            stored, no GT or images generated yet.
            ---------------------------------------------------------------
            %}

            %% Defaults
            AU = 149597870.7; % AU conversion [km/AU]
            G = 6.67259*10^-20; % Gravitational Constant
            % Asteroid
                defaultAst = ASTEROID();
            % Spacecraft
                tEpoch = datenum(2019,9,4,0,0,0)+1721058.5;  % JD epoch (days)
                oeACI = [35 0.01 deg2rad(80) deg2rad(220) 0 1.5]';
                defaultSc = SPACECRAFT(tEpoch,oeACI,defaultAst.mu);
                defaultNSc = 2;            
            % Simulation
                defaultTEp = tEpoch;
                defaultTInt = 5*60;
                defaultNIm = 500;
                
            %% Input Parser
            p = inputParser;
            addParameter(p,'name',date,@ischar)
            addParameter(p,'asteroid',defaultAst)
            addParameter(p,'nSpacecraft',defaultNSc,@isnumeric)
            addParameter(p,'spacecraft',{})
            addParameter(p,'camera','default',@ischar)
            addParameter(p,'tEpoch',defaultTEp,@isnumeric)
            addParameter(p,'tInterval',defaultTInt,@isnumeric)
            addParameter(p,'nImages',defaultNIm,@isnumeric)
            parse(p,varargin{:})
            
            %% Check Input
            switch p.Results.camera
                case 'PtGrey17'
                    % Point Grey 17mm
                    defaultSc.camera = CAMERA(17,[1200 1920],[5.86 5.86],'PtGrey17');
                case 'NEAR'
                    % NEAR Shoemaker
                    defaultSc.camera = CAMERA(168,[244 537],[27 16],'NEAR');
                case 'OSIRIS'
                    % OSIRIS REx's NavCam
                    defaultSc.camera = CAMERA(7.6,[1944 2592],[2.2 2.2],'NavCam');
                case 'NanoCam'
                    % GOMspace NanoCam
                    defaultSc.camera = CAMERA(8,[2048 1536],[3.2 3.2],'NanoCam');
                otherwise
                    % Point Grey
                    defaultSc.camera = CAMERA(12,[1200 1920],[5.86 5.86],'PtGrey12');
            end
            if isempty(p.Results.spacecraft)
                sc = cell(p.Results.nSpacecraft,1);
                for n = 1:p.Results.nSpacecraft
                    sc{n} = defaultSc;
                end
                gt.spacecraft = sc;
                gt.nSpacecraft = p.Results.nSpacecraft;
                for n = 1:gt.nSpacecraft
                    gt.spacecraft{n}.name = ['Orbiter',num2str(n)];
                end
            else
                gt.nSpacecraft = size(p.Results.spacecraft,1);
                gt.spacecraft = p.Results.spacecraft;
            end
            
            %% Parse Remaining Input
            gt.name = p.Results.name;
            gt.asteroid = p.Results.asteroid;
            gt.tEpoch = p.Results.tEpoch;
            gt.tInterval = p.Results.tInterval;
            gt.nImages = p.Results.nImages;
            tIntD = gt.tInterval/86400;
            gt.tJD = (gt.tEpoch:tIntD:(gt.tEpoch+tIntD*(gt.nImages-1)))';
        end
        
        function gt = setProp(gt,varargin)
            % Change properties of an existing gt. USE CAREFULLY
            %{
            ---------------------------------------------------------------
            INPUT: gt = gt.setProp('option1',value1,...)
                Input parsing is supported with defaults. ansGT = ANSGT() 
                sets all properties to default values. Input the name of
                the property you want to change as a string followed by the
                value to want to change it to. Exceptions...
                nSpacecraft:    int, number of spacecraft. Changing this
                                will make GT repopulate gt.spacecraft with
                                the new number
                camera:         camera, changing this will change the
                                camera of all sc in gt.spacecraft
                
            ---------------------------------------------------------------
            OUTPUT:
                gt:             GROUNDTRUTH object, all simulation parameters
                                stored, no GT or images generated yet.
            ---------------------------------------------------------------
            %}
            p = inputParser;
            % File System
            addParameter(p,'name',gt.name,@ischar)
            addParameter(p,'dirCurrent',gt.dirCurrent,@ischar)
            addParameter(p,'dirAstModels',gt.dirAstModels,@ischar)
            addParameter(p,'dirData',gt.dirData,@ischar)
            % Simulation
            addParameter(p,'asteroid',gt.asteroid)
            addParameter(p,'nSpacecraft',gt.nSpacecraft,@isnumeric)
            addParameter(p,'spacecraft',gt.spacecraft)
            addParameter(p,'camera','',@ischar)
            addParameter(p,'cameraObj',[])
            addParameter(p,'tEpoch',defaultTEp,@isnumeric)
            addParameter(p,'tInterval',defaultTInt,@isnumeric)
            addParameter(p,'nImages',defaultNIm,@isnumeric)
            parse(p,varargin{:})
            
            %% Simple Changes
            gt.name = p.Results.name;
            gt.dirCurrent = p.Results.dirCurrent;
            gt.dirAstModels = p.Results.dirAstModels;
            gt.dirData = p.Results.dirData;
            gt.asteroid = p.Results.asteroid;
            gt.tEpoch = p.Results.tEpoch;
            gt.tInterval = p.Results.tInterval;
            gt.nImages = p.Results.nImages;
            
            %% Spacecraft Updates
            sc = gt.spacecraft{1};
            switch p.Results.camera
                case 'PtGrey17'
                    % Point Grey 17mm
                    cam = CAMERA(17,[1200 1920],[5.86 5.86],'PtGrey17');
                case 'PtGrey12'
                    % Point Grey 12mm
                    cam = CAMERA(12,[1200 1920],[5.86 5.86],'PtGrey17');
                case 'NEAR'
                    % NEAR Shoemaker
                    cam = CAMERA(168,[244 537],[27 16],'NEAR');
                case 'OSIRIS'
                    % OSIRIS REx's NavCam
                    cam = CAMERA(7.6,[1944 2592],[2.2 2.2],'NavCam');
                case 'NanoCam'
                    % GOMspace NanoCam
                    cam = CAMERA(8,[2048 1536],[3.2 3.2],'NanoCam');
                otherwise
                    cam = sc.camera;
            end
            if ~isEmpty(p.Results.cameraObj)
                cam = p.Results.cameraObj;
            end
            
            if (~isEmpty(p.Results.cameraObj) || ~isEmpty(p.Results.camera)) && (p.Results.nSpacecraft == gt.nSpacecraft)
                % Change camera of all existing sc
                for n = 1:gt.nSpacecraft
                    gt.spacecraft{n}.camera = cam;
                end
            elseif (~isEmpty(p.Results.cameraObj) || ~isEmpty(p.Results.camera)) && (p.Results.nSpacecraft ~= gt.nSpacecraft)
                % Change the number of sc based on gt.spacecraft{1} and
                % change their camera
                sc.camera = cam;
                scs = {sc};
                gt.nSpacecraft = p.Results.nSpacecraft;
                scs = repmat(scs,[gt.nSpacecraft,1]);
                gt.spacecraft = scs;
            else
                % Change the number of sc based on gt.spacecraft{1} only
                scs = {sc};
                gt.nSpacecraft = p.Results.nSpacecraft;
                scs = repmat(scs,[gt.nSpacecraft,1]);
                gt.spacecraft = scs;
            end
            
        end
        
        function gt = compGT(gt)
            % Compute all of the ground truth meta data (not the images)
            %{
            ---------------------------------------------------------------
            INPUT: gt = gt.compGT()
                none
            ---------------------------------------------------------------
            OUTPUT:
                gt:         GROUNDTRUTH object
            ---------------------------------------------------------------
            NOTES:
                - All sc data will be saved in the Images folder associated
                  with each spacecraft:
                  [ansGT.dirCurrent,'\',ansGT.dirData,'\',ansGT.spacecraft{n}.name,'\Images']
            ---------------------------------------------------------------
            %}
            
            %% Set Up File System
            for n = 1:gt.nSpacecraft
                dirSpacecraft = [gt.dirCurrent,'\',gt.dirData,'\',gt.spacecraft{n}.name];
                if ~exist(dirSpacecraft,'dir')
                    mkdir(dirSpacecraft)
                end
                if ~exist([dirSpacecraft,'\Images'],'dir')
                    mkdir([dirSpacecraft,'\Images'])
                end
            end
            addpath(genpath([gt.dirCurrent,'\',gt.dirData]));
            
            %% Initialize
            stateGTsize = gt.nSpacecraft*6;
            gt.stateGT = zeros(gt.nImages,stateGTsize);
            gt.meta = zeros(gt.nImages,12,gt.nSpacecraft);
            % [JD,rAstSCI,rSatACI,eul,Ldxn] [1 x 12]
            % eul = rotm2eul(rotm,'ZYX')
            
            %% Compute Data
            muSun = 1.3271244004193938E11; % Grav Param of Sun [km^3/s^2]
            Reqec = rotEQUtoECL();
            common = zeros(gt.nImages,4);
            % Data common to all SC
            for i = 1:gt.nImages
                % Asteroid
                tAst = (gt.tJD(i) - gt.asteroid.tEpoch)*86400;
                rAstSCI = Reqec'*propOEtoRV(gt.asteroid.oeHCI,muSun,tAst);
                common(i,:) = [gt.tJD(i) rAstSCI'];
            end
            gt.meta(:,1:4,:) = repmat(common,1,1,gt.nSpacecraft);
            % Data unique to each SC
            for n = 1:gt.nSpacecraft
                for i = 1:gt.nImages
                    rAstSCI = gt.meta(i,2:4,n);
                    % Spacecraft Position
                    tSat = (gt.tJD(i) - gt.spacecraft{n}.tEpoch)*86400;
                    [rSatACI,vSatACI] = propOEtoRV(gt.spacecraft{n}.oeACI,gt.asteroid.mu,tSat);
                    % Spacecraft Attitude
                    R = rotWldCam(rSatACI,vSatACI,[0;0;0]);
                    eul = rotMtoEul(R);
                    % Lighting Direction
                    dat = transPt32(-rAstSCI,rSatACI,R,gt.spacecraft{n}.camera)';
                    Ldxn = -dat'./norm(dat);
                    a = acosd(dot(rSatACI,-rAstSCI)/(norm(rSat)*norm(-rAstSCI)));
                    if a > 90
                        Ldxn = -Ldxn;
                    end
                end
            end
            
        end
        
        function ansGT = readGT(ansGT)
            % Read all of the ground truth data in from saves .png and .csv
            % ansGT = ansGT.readGT()
            % OR ansGT = readGT(ansGT)
            %{
            ---------------------------------------------------------------
            INPUT: none
            ---------------------------------------------------------------
            OUTPUT:
                gt:         GROUNDTRUTH object
            ---------------------------------------------------------------
            %}
            
        end
        
        function ansGT = genIms(ansGT)
            % Generate all of the images for the GT
            % ansGT = ansGT.genIms()
            % OR ansGT = genIms(ansGT)
            %{
            ---------------------------------------------------------------
            INPUT: none
            ---------------------------------------------------------------
            OUTPUT:
                gt:         GROUNDTRUTH object
            ---------------------------------------------------------------
            NOTES:
                - compGT must be called first!
                - All images will be saved in the Images folder associated
                  with each spacecraft:
                  [ansGT.dirCurrent,'\',ansGT.dirData,'\',ansGT.spacecraft{n}.name,'\Images']
            ---------------------------------------------------------------
            %}

        end
        
        function ansGT = detectFeat(ansGT)
            % Detect all of the features in the images
            % ansGT = ansGT.detectFeat()
            % OR ansGT = detectFeat(ansGT)
            %{
            ---------------------------------------------------------------
            INPUT: none
            ---------------------------------------------------------------
            OUTPUT:
                gt:         GROUNDTRUTH object
            ---------------------------------------------------------------
            %}
        end
    end
end