/*
*	Global variables
*/
var line_id = new Array();
var line_data_src = new Array();
var axis_name_Y = '';

/*
*	Function to plot the chart 
*	Params: 
*		chart_title: show on the top of the chart
*		axis_name_Y: Y-axis name (X-axis name is always "Sampling points")
*		div_id: id of <div> 
*		data_source_array: Array which stores the sample data
*		line_id_array: Array which stores the line id label.
 */
function genChart(chart_title, axis_name_Y, div_id, data_source_array, line_id_array){

	/*
	*	Local variabels 
	*/
	line_color = ['#8D9386', '#2B39EE', '#FC1D3F', '#008080'];

	var chart = new JSChart(div_id, 'line');
	//Set data source, chart legend and line color
	for (var i = 0; i < data_source_array.length; i++)
	{
		chart.setDataArray(data_source_array[i], line_id_array[i]);
		chart.setLegendForLine(line_id_array[i], line_id_array[i]);  //Make the line id to be same as legend name
		if (!line_color[i]){
			alert("The number of color is not fulfill the number of lines, please add more colors");
		}
		else{
			chart.setLineColor(line_color[i], line_id_array[i]);
		}
	}

	//Set canvas property
	// chart.setSize($("#cpu_usage").offsetWidth-50, $("#cpu_usage").offsetHeight-50);
	chart.setSize(window.innerWidth-50, window.innerHeight-50);

	//Set title property
	chart.setTitle(chart_title);
	chart.setTitleFontSize(30)
	chart.setTitleColor('#0000FF');

	//Set legend property
	chart.setLegendShow(true);
	chart.setLegendFontSize(15);
	chart.setLegendPadding(65);

	//Set Axis property
	chart.setAxisColor('#9F0505');
	chart.setAxisValuesColor('#333639');
	chart.setAxisNameColor('#333639');
	chart.setAxisAlignFirstX(true);
	chart.setAxisAlignFirstY(true);
	chart.setAxisNameX("Sampling points");
	chart.setAxisNameY(axis_name_Y, true);
	chart.setAxisNameFontSize(15);
	chart.setAxisValuesFontSize(11);
	chart.setAxisValuesNumberY(0);
	chart.setAxisPaddingLeft(140);
	chart.setAxisPaddingRight(140);
	chart.setAxisPaddingTop(100);
	chart.setAxisPaddingBottom(45);
	chart.setTextPaddingLeft(80);
	chart.setTextPaddingBottom(6);
	chart.setGridColor('#a4a4a4');
	chart.setGraphExtendX(true);

	//Set line property
	chart.setLineWidth(2);
	//Set plot speed
	chart.setLineSpeed(100);

	chart.draw();
}

function initLineProp(line_id, line_data_src, object){

	var i = 0;
	for (line in object)
	{
		line_id[i] = line; // Prepare line id
		line_data_src[i] = object[line]; // Prepare line data source
		i++;
	}
}

/*
*	Generate the table on system statistic
*/
function genStatTable() {
        var innerhtml = '';
        var innerline;
        var title;
        var count;

        for (var i = 0; i < app_sum.table_tr_arr.length; i++)
        {
            //initialize innerline and count
            innerline = '';
            count = 0;

            title = app_sum.table_tr_arr[i];

            for (tmp_title in app_sum.table_tr_data)
            {
                if (tmp_title == title)
                {
                    var iter = true;
                    for (sub_title in app_sum.table_tr_data[title])
                    {
                        if (iter)
                        {
                            sub_value = app_sum.table_tr_data[title][sub_title];
                            innerline = innerline + '<td width="39%" bgcolor="#D7E4BC"><strong>' + sub_title + '</strong></td><td width="7%" align="right">' + sub_value + '</td></tr>';
                        }
                        else
                        {
                            sub_value = app_sum.table_tr_data[title][sub_title];
                            innerline = innerline + '<tr><td bgcolor="#D7E4BC"><strong>' + sub_title + '</strong></td><td width="7%" align="right">' + sub_value + '</td></tr>';
                        }
                        iter = false;
                        count++
                    }
                }
            }
            innerhtml = innerhtml + '<tr><td width="10%" rowspan="' + count + '" bgcolor="#D7E4BC"><strong>' + title + '</strong></td>';
            innerhtml = innerhtml + innerline
        }
        innerhtml = '<table class="table" width="75%" border="0" cellpadding="0" cellspacing="0">' + innerhtml + '</table>'

        //insert into table tag
        return innerhtml;
}