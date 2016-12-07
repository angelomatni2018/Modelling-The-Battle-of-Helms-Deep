function out = PlotTotalTroopsAcrossTime(troopMatrix, army, timeInterval, soldierNames)
    figure;
    hold on;
    title({['Total troops for an army for each time step']});
    xlabel('Number of troops');
    ylabel('Time step');    
    totalTroops = sum(troopMatrix,1);
    % for each soldier type
    for ii = 1:size(troopMatrix,2)
        soldier = totalTroops(:,ii,army,:);
        plot(timeInterval,reshape(soldier,1,size(soldier,4)), ...
            'DisplayName',soldierNames{ii});
    end
    
    legend('show')
end