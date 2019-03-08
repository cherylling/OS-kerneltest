

cpufreq_files="affected_cpus scaling_available_governors bios_limit scaling_cur_freq cpuinfo_cur_freq scaling_driver\
               cpuinfo_max_freq scaling_governor cpuinfo_min_freq scaling_max_freq cpuinfo_transition_latency \
               scaling_min_freq related_cpus scaling_setspeed scaling_available_frequencies "

max()
{
	max_freq_ret=`echo $@ | awk 'BEGIN {max=0} {for(i=1;i<=NF;i++)if(max<$i)max=$i} END{print max}'`
	echo $max_freq_ret
}

min()
{
	min_freq_ret=`echo $@ | awk 'BEGIN {min=6000000} {for(i=1;i<=NF;i++)if(min>$i)min=$i} END{print min}'`
	echo $min_freq_ret
}

middle()
{
	middle_freq_ret=`echo $@ | awk '{print $(NF/2)}'`
	echo $middle_freq_ret
}
