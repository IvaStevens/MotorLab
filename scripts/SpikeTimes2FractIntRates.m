function [spike_rates, bin_times] = SpikeTimes2FractIntRates( spike_times, bin_size, spike_time_span)

% [spike_rates, bin_times] = SpikeTimes2FractIntRates( spike_times, bin_size, spike_time_span)
%
% Takes a vector of spike time values (in seconds) and turns it into a
% vector of firing rates using the fractional intervals method in bins of bin_size
% (make sure this is also in seconds, and has to be an 
% integer multiple of a millisecond (for reasons of computational efficiency)). 
% spike_time_span is a two-element vector containing the
% times that the first and last bin should correspond to.
%
% Meel Velliste, Sept 19, 2011

% First create spike counts in 1 ms bins, because there is a computationally
% efficient way to do this in matlab (using vector processing, not
% for-looping) assuming that no two spikes occur within the same
% millisecond. (Any multiple occurrences of spikes in the same millisecond
% will be counted as a single spike. Should not happen very often, but if
% it does, it's a sacrifice in the name of computational efficiency. 
% Besides, even if it does happen, those repeat spikes within the same
% millisecond cannot be real, but rather must be noise because real spikes
% have a refractory period of about 2 ms.)
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
% Calculate number of total bins
total_bins = ceil( (tf-t0) / bin_size);
total_small_bins = total_bins * small_bins_per_bin;
% Create a mask of small bins that contain a spike
spike_bin_mask = false( 1, total_small_bins);
spike_bin_mask(spike_bin_indices) = true;

% Eliminate any duplicate spike bin indices
% where multiple spikes would have been in the same small bin
% because they would mess up inverval indexing later on
unique_spike_bin_indices = unique( spike_bin_indices);

% Create bin_size fractional interval counts from interval durations.
% Interval before first and after last spike is not known, but assume them 
% to be infinite
quantized_spike_times = small_bin_size * unique_spike_bin_indices;
interval_durations = [inf diff( quantized_spike_times) inf];
interval_rates = 1 ./ interval_durations;
interval_indices = cumsum( spike_bin_mask) + 1;
small_rates = interval_rates(interval_indices);

% Turn the 1 ms firing rates into larger bin rates by averaging the
% appropriate number of consecutive bins
small_rates = reshape( small_rates, [small_bins_per_bin, total_bins]);
spike_rates = nanmean( small_rates);
bin_times = spike_time_span(1) + (0:bin_size:(total_bins-1)*bin_size);
