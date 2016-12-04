function out = PlotTotalTroopsAcrossTime(troopMatrix, army, timeInterval)
    figure;
    hold on;
    totalTroops = sum(troopMatrix,1);
    % for each soldier type
    for ii = 1:size(troopMatrix,2)
        soldier = totalTroops(:,ii,army,:);
        plot(timeInterval,reshape(soldier,1,size(soldier,4)));
    end
end