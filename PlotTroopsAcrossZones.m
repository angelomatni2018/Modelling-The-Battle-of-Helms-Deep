function out = PlotTroopsAcrossZones(troopMatrix, army, timeInterval)
    figure;
    hold on;
    totalTroopsX = sum(troopMatrix,2);
    % for each zone
    for ii = 1:size(troopMatrix,1)
        zone = totalTroopsX(ii,:,army,:);
        plot(timeInterval,reshape(zone,1,size(zone,4)));
    end
end