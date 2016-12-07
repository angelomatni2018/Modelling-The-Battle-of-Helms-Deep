function out = PlotTroopsAcrossZones(troopMatrix, army, timeInterval)
    figure;
    hold on;
    title(['Troops for army ',num2str(army),' for each time step']);
    xlabel('Number of troops');
    ylabel('Time step');
    totalTroopsX = sum(troopMatrix,2);
    % for each zone
    for ii = 1:size(troopMatrix,1)
        zone = totalTroopsX(ii,:,army,:);
        plot(timeInterval,reshape(zone,1,size(zone,4)),...
            'DisplayName',['zone ',num2str(ii)]);
    end
    
    legend('show')
end