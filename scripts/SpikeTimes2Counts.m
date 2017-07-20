function [spike_counts, count_times] = SpikeTimes2Counts( spike_times, bin_size, spike_time_span)

% [spike_counts, count_times] = SpikeTimes2Counts( spike_times, bin_size, spike_time_span)
%
% Takes a vector of spike time values (in seconds) and turns it into a vector of spike
% counts in bins of bin_size (make sure this is also in seconds, and has to be an 
% integer multiple of a millisecond (for reasons of computational efficiency)). 
% spike_time_span is a two-element vector containing the
% times that the first and last bin should correspond to.
%
% Meel Velliste, Aug 2009
% Corrected by Meel Velliste Sept 19, 2011 to center the bins correctly on
% the bin times (used to be that bin time would refer to beginning of bin)

% First create counts in 1 ms bins, because there is a computationally
% efficient way to do this in matlab (using vector processing, not
% for-looping) assuming that no two spikes occur within the same
% millisecond. (Any multiple occurrences of spikes in the same millisecond
% will be counted as a single spike. Should not happen very often, but if
% it does, it's a sacrifice in the name of computational efficiency. 
% Besides, even if it does happen, those repeat spikes within the same
% millisecond cannot be real, but rather must be noise because real spikes
% have a refractory period of about 2 ms.)
% extend time by half bin width so that first and last bin will be centered
% on start and end time
small_bin_size = .001;
t0 = spike_time_span(1) - (bin_size-small_bin_size)/2;
tf = spike_time_span(2) + (bin_size-small_bin_size)/2;
% Eliminate spikes before and after selected time span
spike_times(spike_times<t0) = [];
spike_times(spike_times>tf) = [];
% Make the times relative to initial time
spike_times = spike_times - t0;
% Bin them in small 1 ms bins
small_bins_per_bin = round( bin_size / small_bin_size);
spike_bin_indices = round( spike_times / small_bin_size) + 1;
total_bins = ceil( (tf-t0) / bin_size);
total_small_bins = total_bins * small_bins_per_bin;
small_counts = zeros( 1, total_small_bins);
small_counts(spike_bin_indices) = 1;

% Turn the 1 ms counts into bin_size counts by summing the appropriate
% number of 1 ms bins.
small_counts = reshape( small_counts, [small_bins_per_bin, total_bins]);
spike_counts = sum( small_counts);
count_times = spike_time_span(1) + (0:bin_size:(total_bins-1)*bin_size);
