function out = PlotTotalTroopsAcrossTime(troopMatrix, army, timeInterval, soldierNames)
    figure;
    hold on;
    title({['Total troops for army ',num2str(army),' for each time step']});
    ylabel('Number of troops');
    xlabel('Time step');    
    totalTroops = sum(troopMatrix,1);
    % for each soldier type
    for ii = 1:size(troopMatrix,2)
        soldier = totalTroops(:,ii,army,:);
        if sum(soldier) > 0
        plot(timeInterval,reshape(soldier,1,size(soldier,4)), ...
            'DisplayName',soldierNames{ii});
        end
    end
    
    legend('show')
end