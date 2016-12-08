
clear; clc;

unitNames = {
  'Infantry'
  'Archers'
  'Uruk-hai'
};

armyNames = {
    'Rohirrim'
    'Mordor'
};
 

numTypes = length(unitNames);
numZones = 3;
numArmies = length(armyNames);

% armies: an array of # of troops for:
% dimension 1: zone (1, 2, ...)
% dimension 2: soldier type (rifleman, artillery, ...)
% dimension 3: army type (union, confederate, ...)
% each initialization is for one army
% notice zones (rows) only contain troops from one army

% armies = zeros(numZones, numTypes, numArmies);
% Initial conditions
armies = [           % Rohirrim Army
    0     0   0      % First zone
    0     0   0      % Second zone
    200   100 0      % Third Zone
];
armies(:,:,2) = [
    0     0   10000
    0     0   0 
    0     0   0
];

% ---------------------------------------------------------------- %

% flowRate: maximum flow rate for a given unit for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type
% each initialization is for one soldier type

flowRate = zeros(numZones, numZones, numTypes);
flowRate(:,:,1) = [        
    0   200  0
    0   0  200 
    0   0  0
];
flowRate(:,:,2) = flowRate(:,:,1);
flowRate(:,:,3) = flowRate(:,:,1);

% ---------------------------------------------------------------- %

% choiceRate: chosen flow rate (between 0 and 1) for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: army type
% dimension 4: soldier type
% each set of initializations is for one army and its soldier types
% IMPORTANT TO KNOW: If an army doesn't have flows, then they 
% should be at the end of this 4d array. Otherwise, space would be 
% wasted for a bunch of 0 filled matrices

mordorInfantryChoice = [
    0 1 0
    0 0 1
    0 0 0
   
];

mordorArchersChoice = [
    0 1 0
    0 0 1
    0 0 0
]; 

mordorUrukHaiChoice = [
    0 1 0
    0 0 1
    0 0 0
   
]; 

choiceRate = cat(3,mordorInfantryChoice,mordorArchersChoice,  mordorUrukHaiChoice);
choiceRate(:,:,:,2) = choiceRate(:,:,:,1);


% ---------------------------------------------------------------- %

% survivalRate: survival rate from transfer of troops for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type
% if the third dimension type is of size 1, all troops have the same
% survival rate when crossing from zone A to B

survivalFactor = .7;
survivalRate = [
    0 .6  0 
    .7 0 .8 
    0 .6  0 
];

% ---------------------------------------------------------------- %

% killRate: effectiveness of troops killing other troops for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type in A
% dimension 4: soldier type in B
% if the third and fourth dimension are of size 1, all troops adopt
% the same killing effectiveness against all other troops
killRate = zeros(numZones, numZones, numTypes, numTypes);
% infantry Attacks Urukhai
killRate(:,:,1,3) = [
    .4 0 0 
    0 .4 0 
    0 0 .4 
];

% Uruk-hai attacks Infantry
killRate(:,:,3, 1) = [
    .5 0 0 
    0 .5 0 
    0 0 .5 
];
% Uruk-hai attacks archer
killRate(:,:,3, 2) = [
    .5 0 0 
    0 .5 0 
    0 0 .5
];
% Archer attacks Uruk-hai
killRate(:,:,2, 3) = [
    .6 .8  .4 
    .8 .6  .8 
    .4 .8  .6
];
%killRate = cat(4, troopXattackY);

% ---------------------------------------------------------------- %

time = 1;
states(:,:,:,time) = armies(:,:,:);

% Used to track size of survivalRate dimension 3
survivalI = 1;
incSurvive = (size(survivalRate,3) > 1);

transferAmts = zeros(size(flowRate,1),size(flowRate,3));

% Used to track size of killRate dimension 3/4
killI = 1;
killJ = 1;
incKill = (size(killRate,3) > 1);

debugNumRuns = 1000; %
while (AllArmiesAlive(armies) && time < debugNumRuns)
    
    transferAmts = zeros(size(flowRate,1),size(flowRate,3),size(armies,3));
    
    % Transfer of troops for each army xx
    for xx = 1:min(size(armies,3))
        
        % fprintf('army %d',xx);
        % Calculate transfer of troops
        transferRate = zeros(numZones, numZones, numTypes);
        for i=1:3
            transferRate(:,:,i) = flowRate(:,:,i) .* choiceRate(:,:,i,xx);
        end
        
        % How many troops of type dim 2 survive making it to zone dim 1
        % For each zone ii to zone jj
        for ii = 1:size(transferRate,1)
            for jj = 1:size(transferRate,2)
                % troops don't transfer within a zone, just between
                if (ii == jj)
                    continue
                end

            % For soldier type kk
                survivalI = 1;
                for kk = 1:size(armies,2)
                    transfer = transferRate(ii,jj,kk);
                    
                    if (transfer > 0)
                        %fprintf('zone %d to %d\n',ii,jj);
                        %fprintf('before transfer: %d\n',transfer);
                        % If they left, transfer from ii would be negative
                        outOfZone = min(0,transferAmts(ii,kk));
                        armiesLeft = armies(ii,kk,xx) + outOfZone;
                        % Only transfer as many units as left in zone
                        %fprintf('for army %d troop %d, %d to %d, amount: %d %d\n',...
                        %    xx,kk,ii,jj,outOfZone,armies(ii,kk,xx))
                        transfer = min(transfer,armiesLeft);
                        survived = floor(transfer * survivalFactor * ...
                            survivalRate(ii,jj,survivalI));
                        %fprintf('after transfer: %d, survived: %d\n',transfer, survived);
                        transferAmts(ii,kk,xx) = transferAmts(ii,kk,xx) - transfer;
                        transferAmts(jj,kk,xx) = transferAmts(jj,kk,xx) + survived;
                    end
                    survivalI = survivalI + incSurvive;
                end
            end
        end
        
        % Execute transfer of troops

        % For zone ii and soldier type jj
        for ii = 1:size(transferAmts,1)
            for jj = 1:size(transferAmts,2)
                armies(ii,jj,xx) = armies(ii,jj,xx) + transferAmts(ii,jj,xx);
            end
        end
    end

    % Combat for each army xx against yy
    killingAmts = zeros(size(armies));
    for xx = 1:size(armies,3)
    for yy = 1:size(armies,3)
        % An army tends not to attack itself. That's just plain silly.
        if (xx == yy)
            continue;
        end
        % for each soldier type
        killI = 1;
        for kk = 1:size(armies,2)
            % from zone A to zone B
            for ii = 1:size(killRate,1)
            for jj = 1:size(killRate,2)

                % attacking each soldier type
                killJ = 1;
                for ll = 1:size(armies,2)
                    deaths = floor(armies(ii,kk,xx) * ...
                        killRate(ii,jj,killI,killJ));
                    killingAmts(jj,ll,yy) = killingAmts(jj,ll,yy) + deaths;
                    %fprintf('zone %d to %d, troop %d to %d, army %d to %d, army attacking: %d, kill rate: %d, killI: %d, killJ: %d\n' ...
                    %    ,ii,jj,kk,ll,xx,yy,armies(ii,kk,xx),killRate(ii,jj,killI,killJ),killI,killJ);
                    killJ = killJ + incKill;
                end
            end
            end
            
            killI = killI + incKill;
        end
    end
    end
    time = time + 1;
    states(:,:,:,time) = max(zeros(size(armies)),armies - killingAmts);
    armies = states(:,:,:,time);
    if (isequal(states(:,:,:,time-1),states(:,:,:,time)))
        break;
    end
end

% Plots army total troop value for each iteration 
PlotTotalTroopsAcrossTime(states,size(armies,3),1:time,unitNames,armyNames);

% Plots army troops across zones for each iteration
PlotTroopsAcrossZones(states,size(armies,3),1:time, armyNames);



