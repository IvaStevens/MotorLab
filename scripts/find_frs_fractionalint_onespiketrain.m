function frs = find_frs_fractionalint_onespiketrain(spike_times_wholetrial, start_times, binsize)
%frs = find_frs_fractionalint_onespiketrain(spike_times_wholetrial, start_times, binsize)
%
% Fractional interval firing rate for one spike train. 
%
% Parameters
% ----------
% spikes_times_wholetrial : [1 x N] double
%     The spikes times in seconds.
% start_times : [1 x M] double
%     The start of each time bin, in seconds. Start times do not have to be
%     regularly spaced.
% binsize : double
%     The size of each bin, in seconds.
%
% Returns
% -------
% frs : [1 x M] double
%     The firing rate for each bin in spikes per second.
%
% BJ, 2005
% sdk29@pitt.edu 2016-12

stop_times = start_times+binsize;

frs = zeros(1, length(start_times));

num_spikes_wholetrial = length(spike_times_wholetrial);
poi_start = start_times(1);
poi_stop = stop_times(end);
spike_times_poi = spike_times_wholetrial(spike_times_wholetrial >= poi_start & spike_times_wholetrial <= poi_stop);
num_spikes_poi = length(spike_times_poi);
%if no spikes in period of interest in that trial, fr in each bin is zero.
if num_spikes_poi == 0,
    return
    %if no spikes in period of interest, fr is zero for each bin
else
    %if there are any spikes before the 1st bin or after the last
    %bin in that trial, use the real spike times.
    %Otherwise, pretend previous ISI of 1st spike was mean ISI 
    %(or start of 1st bin, if earlier) and/or next ISI of last 
    %spike is mean ISI (or end of last bin, if later). This 
    %should also be a reasonable assumption for the case where only
    %1 spike occurred in period of interest.
    total_poi = poi_stop - poi_start;
    mean_ISI_poi = total_poi/num_spikes_poi;
    
    last_spiketime_before_first_bin = max(spike_times_wholetrial(spike_times_wholetrial < poi_start));
    if isempty(last_spiketime_before_first_bin),
        last_spiketime_before_first_bin = min(spike_times_poi(1) - mean_ISI_poi, poi_start); %might be negative if poi_start = 0.
    end
    
    next_spiketime_after_last_bin = min(spike_times_wholetrial(spike_times_wholetrial > poi_stop));
    if isempty(next_spiketime_after_last_bin),
        next_spiketime_after_last_bin = max(spike_times_poi(end) + mean_ISI_poi, poi_stop);
    end
    
    spike_times = [last_spiketime_before_first_bin spike_times_poi next_spiketime_after_last_bin];
    
    parfor bin_number = 1:length(start_times),
        start_time = start_times(bin_number);
        stop_time = stop_times(bin_number);
        spikes_in_bin = spike_times(spike_times > start_time & spike_times < stop_time);
        %I'm assuming that the only time spikes will fall at
        %exactly the border of a bin will be if I've put an imaginary one at
        %the beginning of the first bin or the end of the last bin,
        %so don't want to count those here... but do want to count
        %them below, so using <= and >= there.
        num_spikes_in_bin = length(spikes_in_bin);
        
        if num_spikes_in_bin == 0,
            %find ISI in which this bin falls, calculate fraction
            %of the ISI that bin takes up
            ISI_start = max(spike_times(spike_times <= start_times(bin_number)));
            ISI_end = min(spike_times(spike_times >= stop_times(bin_number)));
            ISI = ISI_end - ISI_start;
            part_int_count = binsize/ISI;
            
        elseif num_spikes_in_bin >= 1,
            %find previous ISI of 1st spike, find fraction of previous ISI in
            %this bin; find next ISI of last spike, find fraction of next ISI in
            %this bin; add them together to get partial interval
            %count. Add another count for each spike > 1.
            
            ISI_prev_start = max(spike_times(spike_times <= start_times(bin_number)));
            ISI_prev_end = spikes_in_bin(1);
            ISI_prev = ISI_prev_end - ISI_prev_start;
            first_fractional_count = (spikes_in_bin(1) - start_time)/ISI_prev;
            
            ISI_next_start = spikes_in_bin(end);
            ISI_next_end = min(spike_times(spike_times >= stop_times(bin_number)));
            ISI_next = ISI_next_end - ISI_next_start;
            last_fractional_count = (stop_time - spikes_in_bin(end))/ISI_next;

            additional_counts = num_spikes_in_bin - 1;
            part_int_count = first_fractional_count + additional_counts + last_fractional_count;
        end
        frs(bin_number) = part_int_count/binsize;% * 1000; %assumes spike times are in milliseconds
    end
end