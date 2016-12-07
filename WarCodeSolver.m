function [topRank, topChoice] = WarCodeSolver(armyIndex)

% as good as -infinity goes
topRank = -100000;

for advance = linspace(0,1,100)
   
    % cycle through possible choices for normalized parameter of flow
    cArmy1Troop1 = [
        0 advance advance advance
        0 0 0 0
        0 0 0 0
        0 0 0 0
    ];
    % Assuming artillery don't move
    cArmy1Troop2 = [
        0 0 0 0
        0 0 0 0
        0 0 0 0
        0 0 0 0
    ];
    cArmy1Troop3 = [
        0 advance advance advance
        0 0 0 0
        0 0 0 0
        0 0 0 0
    ];

    choices = cat(4,cArmy1Troop1,cArmy1Troop2,cArmy1Troop3);
    
    % Run iterator and get rank, which is defined as
    % number of troops left of army we're optimizing -
    % number of troops left of all other armies
    tempRank = WarCodeIterator(choices,armyIndex, 0);
    if (tempRank >= topRank)
        topChoice = choices;
        topRank = tempRank;
    end
end

% Run iterator with plot flag set to 1
WarCodeIterator(topChoice,armyIndex, 1);
end

function rank = WarCodeIterator(choices, optimizingArmy, plot)

soldierNames = {
  'Rifleman'
  'Artillery'
  'Cavalry'
};

% armies: an array of # of troops for:
% dimension 1: zone (1, 2, ...)
% dimension 2: soldier type (rifleman, artillery, ...)
% dimension 3: army type (union, confederate, ...)
% each initialization is for one army
% notice zones (rows) only contain troops from one army

armies = [
    110 90 60
    0 0 0 
    0 0 0
    0 0 0
];
armies(:,:,2) = [
    0 0 0
    0 0 0
    0 0 0
    100 100 40
];

% ---------------------------------------------------------------- %

% flowRate: maximum flow rate for a given unit for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type
% each initialization is for one soldier type

flowRate = [
    0 50 50 0
    0 0 0 50
    0 0 0 50
    0 0 0 0
];
flowRate(:,:,2) = zeros(size(flowRate)); % Assuming artillery don't move
flowRate(:,:,3) = flowRate(:,:,1);

% ---------------------------------------------------------------- %

% choiceRate: chosen flow rate (between 0 and 1) for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type
% dimension 4: army type
% each set of initializations is for one army and its soldier types
% IMPORTANT TO KNOW: If an army doesn't have flows, then they 
% should be at the end of this 4d array. Otherwise, space would be 
% wasted for a bunch of 0 filled matrices

choiceRate = choices;

% ---------------------------------------------------------------- %

% survivalRate: survival rate from transfer of troops for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type
% if the third dimension type is of size 1, all troops have the same
% survival rate when crossing from zone A to B

survivalFactor = 1;
survivalRate = [
    0 1 1 1
    1 0 1 .8
    1 1 0 .8
    1 1 1 1
];

% ---------------------------------------------------------------- %

% killRate: effectiveness of troops killing other troops for:
% dimension 1: from zone A
% dimension 2: to zone B
% dimension 3: soldier type in A
% dimension 4: soldier type in B
% if the third and fourth dimension are of size 1, all troops adopt
% the same killing effectiveness against all other troops

%troop1Attack1
killRate(:,:,1,1) = [
    0 0 0 0
    0 0 0 0
    0 0 0 .1
    0 0 .1 0
];

%troop1Attack2 = troop1Attack1;
killRate(:,:,1,2) = killRate(:,:,1,1);

%troop1Attack3 
killRate(:,:,1,3) = [
    0 0 0 0
    0 0 0 0
    0 0 0 .05
    0 0 .05 0
];

%troop2Attack1 = troop1Attack1;
%troop2Attack2 = troop1Attack1;
%troop2Attack3 = troop1Attack1;
killRate(:,:,2,1) = [
    0 0 0 .1
    0 0 0 .3
    0 0 0 .3
    .1 .3 .3 0
];

killRate(:,:,2,2:3) = repmat(killRate(:,:,2,1),1,1,1,2);

%troop3Attack1 
killRate(:,:,3,1) = [
    0 0 0 0
    0 0 0 0
    0 0 0 .2
    0 0 .2 0
];

%troop3Attack2 = troop3Attack1;
%troop3Attack3 = troop1Attack1;
killRate(:,:,3,2) = killRate(:,:,3,1);
killRate(:,:,3,3) = killRate(:,:,1,1);

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

debugNumRuns = 100; %
while (AllArmiesAlive(armies) && time < debugNumRuns)
    
    transferAmts = zeros(size(flowRate,1),size(flowRate,3),size(armies,3));
    
    % Transfer of troops for each army xx
    for xx = 1:min(size(armies,3),size(choiceRate,3))
        
        % fprintf('army %d',xx);
        % Calculate transfer of troops
        
        transferRate(:,:,:) = flowRate(:,:,:) .* choiceRate(:,:,:,xx);
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
                if (ii == jj)
                    continue;
                end
                % attacking each soldier type
                killJ = 1;
                for ll = 1:size(armies,2)
                    deaths = floor(armies(ii,kk,xx) * ...
                        killRate(ii,jj,killI,killJ));
                    killingAmts(jj,ll,yy) = killingAmts(jj,ll,yy) + deaths;
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

% Plot if flag is set to 1
if plot == 1
    % Plots army total troop value for each iteration 
    PlotTotalTroopsAcrossTime(states,size(armies,3),1:time,soldierNames);

    % Plots army troops across zones for each iteration
    PlotTroopsAcrossZones(states,size(armies,3),1:time);
end

% Calculate rank
rank = sum(sum(states(:,:,optimizingArmy,time)));
for ii = 1:size(armies,3)
   if ii == optimizingArmy
       continue;
   end
   rank = rank - sum(sum(states(:,:,ii,time)));
end

end






