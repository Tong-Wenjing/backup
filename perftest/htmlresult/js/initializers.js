// Run javascript after DOM is initialized
$(document).ready(function() {

	// $('#body').waypoint('sticky');
	$('.tabs').tabslet();
	var idx = $('.active').index();
	var elem = $('.tabs').find('div')[idx];
	$(elem).html(genStatTable());

/*	$('.tabs_active').tabslet({
		active: 2
	});

	$('.tabs_hover').tabslet({
		mouseevent: 'hover',
		attribute: 'href',
		animation: false
	});

	$('.tabs_animate').tabslet({
		mouseevent: 'click',
		attribute: 'href',
		animation: true
	});

	$('.tabs_rotate').tabslet({
		autorotate: true,
		delay: 3000
	});

	$('.tabs_controls').tabslet();

	$('.before_event').tabslet();
	$('.before_event').on("_before", function() {
		alert('This alert comes before the tab change!')
	});

	$('.after_event').tabslet({
		animation: true
	});
*/
	$('.after_event').on("_after", function() {
		var idx = $('.active').index();
		var elem = $('.tabs').find('div')[idx];
		var id = $(elem).attr('id');

		var line_id = new Array();
		var line_data_src = new Array();
		switch (id){
			case 'sys_stat':  
				//Show the system statistic in a table
				$(elem).html(genStatTable());
				break;
			/*
			*	For the statistic on cpu, memory, disk, paging and so on, will be
			*	shown with a chart.
			*/
			case 'cpu_usage':
				//Set the data source and line id
				initLineProp(line_id, line_data_src, cpu_data.cpu);
				//Set the Y-axis name
				axis_name_Y = "Usage(%)";
				genChart('Cpu Usage', axis_name_Y, 'cpu_usage', line_data_src, line_id);
				break;
			case 'mem_usage':
				//Set the data source and line id
				initLineProp(line_id, line_data_src, mem_data.memory);
				//Set the Y-axis name
				axis_name_Y = "Usage(GB)";
				genChart('Memory Usage', axis_name_Y, 'mem_usage', line_data_src, line_id);
				break;
			case 'disk_usage':
				axis_name_Y = "Usage";
				for (partition in disk_data.disk)
				{
					//firstly add the additional <div> for different partitions
					$(elem).append("<div id=" + partition + "></div>")
					//Then prepare the chart data source and line id
					initLineProp(line_id, line_data_src, disk_data.disk[partition]);
					//finally plot the chart
					genChart("Disk-" + partition, axis_name_Y, partition, line_data_src, line_id);
				}
				break;
			case 'paging_usage':
				//Set the data source and line id
				initLineProp(line_id, line_data_src, paging_data.paging);
				//Set the Y-axis name
				axis_name_Y = "Usage(KB/s)";
				genChart('Paging Usage', axis_name_Y, 'paging_usage', line_data_src, line_id);
				break;
			default:
				alert('The div ' + id + 'does not exist');
		}
	});
	
	$('.before_event').on("_before", function(){
		var idx = $('.active').index();
		var elem = $('.tabs').find('div')[idx];
		// var id = $(elem).attr('id');
		$(elem).html('');
	});

});