function out = PlotTroopsAcrossZones(troopMatrix, timeInterval)
    figure;
    hold on;
    totalTroopsX = sum(troopMatrix,2);
    for ii = 1:size(troopMatrix,1)
        a = totalTroopsX(ii,:,:);
        plot(timeInterval,reshape(a,size(a,3),1,1));
    end
end