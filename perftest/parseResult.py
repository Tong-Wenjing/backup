#!/usr/bin/env python
#-*-coding:utf-8-*-
"""
This module is used for parse the DDEI performance test result.
it will output a .js file which has several json data
"""
import json

class ParseResultError(Exception):
    pass


def parse_summary_result(system_summary, db_summary):
    """
    parse the summarized result which includes:
        1. Email process
        2. System resource
        3. Virtual analysis
        4. Threat detection
    Parameters:
    Return: JSON object
    Exceptions:
    """
    # initialize system resource summary data
    system_summary_dict = parse_system_summary(system_summary)
    #print "system summary dictionary is:", system_summary_dict
    # initialize db summary data
    db_summary_dict = parse_db_summary(db_summary)
    #print "db summary dictionary is:", db_summary_dict
    # combine the two dictionary
    result_dict = system_summary_dict.copy()
    result_dict.update(db_summary_dict)
    return result_dict

def parse_system_summary(file):
    """
    Parse system resource summary data
    Parameters: summary file
    return: dictionary (system resource summary result)
    Exceptions: ParseResultError
    """
    #########################################################
    system_resource_list = ["Avg.CPU total usage(Total 100%)",
                            "Avg.CPU User time(Total 100%)",
                            "Avg.CPU System time(Total 100%)",
                            "Avg.CPU IO wait(Total 100%)",
                            "Avg.Memory used(GB)",
                            "Avg.Memory freed(GB)",
                            "Avg.Memory buffered(GB)",
                            "Avg.Memory cached(GB)",
                            "Avg.Disk await time(ms)",
                            "Avg.Disk svctm time(ms)",
                            "Avg.Disk %util(%)",
                            "Avg.Page in(KB/s)",
                            "Avg.Page out(KB/s)"
                            ]

    system_resource_dict = {}
    #########################################################
    try:
        sys_sum = open(file, 'r')
    except Exception as err:
       raise ParseResultError("Open system summary file fail for [%s]" % err) 

    try:
        items_in_file = sys_sum.readlines()
        # Initialize system resource summary 
	i = 0   
        for item in system_resource_list:
            for line in items_in_file:
                if item == line.split(':')[0]:
                    system_resource_dict[item]=float(line.split(':')[1].strip('\t').strip('\n'))
		    i=i+1
                    break
    except Exception as err:
        raise ParseResultError("Parse system summary result fail for [%s]" % err)
    finally: 
        sys_sum.close()
    return {"System resource":system_resource_dict}
    
def parse_db_summary(file):
    """
    Parse db summary data
    Parameters: db summary file
    return: dictionary (db summary result)
    Exceptions: ParseResultError
    """
    ###############################################################
    email_process_list = ["Total emails",
                          "# of emails with attachments",
                          "Elapse(sec)",
                          "Avg.speed(msg/sec)",
                          "Avg.speed(msg/day)"
                         ]

    virtual_analysis_list = ["# of sandboxed attachments",
                             "# of sandbox completion",
                             "# of high risk detections",
                             "# of medium risk detections",
                             "# of low risk detections",
                             "# of no risk detections",
                             "Avg.Sandcastle analyze time per file per instance(sec)",
                             "Avg.Sandcastle analyze time per file under all instances(sec)",
                             "Total Sandcastle analyze time(sec)",
                             "Total analyze time (include queue time)(sec)"
                            ]

    threat_detection_list = ["Prefiltered",
                             "Virtual analysis",
                             "Total detections"
                            ]

    email_process_dict = {}
    virtual_analysis_dict = {}
    threat_detection_dict = {}
    ################################################################
    try:
        db_sum = open(file, 'r')
    except Exception as err:
       raise ParseResultError("Open db summary file fail for [%s]" % err) 

    try:
        items_in_file = db_sum.readlines()
        
	# Initialize email process summary
	i = 0
        for item in email_process_list:
            for line in items_in_file:
                if item == line.split(':')[0]:
		    value = line.split(':')[1].strip('\t').strip('\n')
		    if not value:
		        value = 0
                    email_process_dict[str(i) + '-' + item] = int(float(value))
		    i = i + 1
                    break
        #print "email process dictionary is:", email_process_dict
        
        # Initialize virtual analyzsis statistic summary
	i = 0
        for item in virtual_analysis_list:
            for line in items_in_file:
                if item == line.split(':')[0]:
                    virtual_analysis_dict[str(i) + '-' + item] = int(line.split(':')[1].strip('\t').strip('\n'))
		    i = i + 1
                    break
        #print "virtual_analysis_dict is:", virtual_analysis_dict

        # Initialize threat detection summary
	i = 0
        for item in threat_detection_list:
            for line in items_in_file:
                if item == line.split(':')[0]:
                    threat_detection_dict[str(i) + '-' + item] = int(line.split(':')[1].strip('\t').strip('\n'))
		    i = i + 1
                    break
        #print "Threat detection dictionary is:", threat_detection_dict
    except Exception as err:
        raise ParseResultError("Parse db summary result fail for [%s]" % err)
    finally:
        db_sum.close()

    return {"Email process":email_process_dict, "Virtual analysis":virtual_analysis_dict, "Threat detection":threat_detection_dict}



def parse_sar_cpu(cpu_result):
    """
    Parse the cpu usage generated by sar -u
    Params: cpu usage summary file
    Return: cpu usage dictionary
    Exceptions: ParseResultError
    """
    cpu_total_usage = []
    cpu_user_usage = []
    cpu_sys_usage = []
    cpu_iowait_usage = []

    try:
        fd = open(cpu_result, 'r')
        i = 1 
        for line in fd.readlines():
            items = line.strip('\n').split('|')
            cpu_user = int(float(items[3]))
            cpu_sys = int(float(items[5]))
            cpu_used = int(100.0 - float(items[8]))
            cpu_iowait = int(float(items[6]))
            
            cpu_total_usage.append([i, cpu_used])
            cpu_user_usage.append([i, cpu_user])
            cpu_sys_usage.append([i, cpu_sys])
            cpu_iowait_usage.append([i, cpu_iowait])
            i = i + 1
    except Exception as err:
        raise ParseResultError("Parse sar cpu statistic result fail for [%s]" % err)
    finally:
        fd.close()
    
    return {"total_cpu_usage":cpu_total_usage,"user_cpu_usage":cpu_user_usage,"sys_cpu_usage":cpu_sys_usage,"iowait_cpu_usage":cpu_iowait_usage}

def parse_sar_memory(mem_result):
    """
    Parse the memory usage generated by sar -r
    Params: memory usage summary file
    Return: memory usage dictionary
    Exceptions: ParseResultError
    """
    used_memory = []
    free_memory = []
    cache_memory = []
    buffer_memory = []

    try:
        fd = open(mem_result, 'r')
        i = 1
        for line in fd.readlines():
            items = line.strip('\n').split('|')
            used_memory_item = (int(items[3]) - int(items[5]) - int(items[6])) / 1024 / 1024
            free_memory_item = (int(items[2]) + int(items[5]) + int(items[6])) / 1024 / 1024
            cache_memory_item = int(items[6]) / 1024 / 1024
            buffer_memory_item = float(items[5]) / 1024 / 1024

            used_memory.append([i, used_memory_item])
            free_memory.append([i, free_memory_item])
            cache_memory.append([i, cache_memory_item])
            buffer_memory.append([i, buffer_memory_item])
            i = i + 1
    except Exception as err:
        raise ParseResultError("Parse sar memory statistic result fail for [%s]" % err)
    finally:
        fd.close()

    return {"used_memory":used_memory,"free_memory":free_memory,"cache_memory":cache_memory,"buffer_memory":buffer_memory}

def parse_sar_disk(disk_result):
    """
    Parse the disk usage generated by sar -d
    Params: disk usage summary file
    Return: disk usage dictionary
    Exceptions: ParseResultError
    """
    disk_await = []
    disk_svctm = []
    disk_util = []

    try:
        fd = open(disk_result, 'r')
        i = 0
        for lines in fd.readlines():
            items = lines.strip('\n').split('|')
            await_time = int(float(items[8]))
            svctm_time = int(float(items[9]))
            util_usage = int(float(items[10]))
            disk_await.append([i, await_time])
            disk_svctm.append([i, svctm_time])
            disk_util.append([i, util_usage])
            i = i + 1
    except Exception as err:
        raise ParseResultError("Parse disk usage fail for [%s]" % err) 
    finally:
        fd.close()
    
    return {"await(ms)":disk_await, "svctm(ms)":disk_svctm, "utilization(%)":disk_util}
    
def parse_sar_page(page_result):
    """
    Parse the paging usage generated by sar -p
    Params: paging usage summary file
    Return: paging usage dictionary
    Exceptions: ParseResultError
    """
    paging_in = []
    paging_out = []

    try:
        fd = open(page_result, 'r')
        i = 1
        for lines in fd.readlines():
            items = lines.strip('\n').split('|')
            page_in_per_sec = int(float(items[2]))
            page_out_per_sec = int(float(items[3]))

            paging_in.append([i, page_in_per_sec])
            paging_out.append([i, page_out_per_sec])
            i = i + 1 
    except Exception as err:
        raise ParseResultError("Parse paging usage fail for [%s]" % err)
    finally:
        fd.close()
    
    return {"paging_in(KB/s)":paging_in, "paging_out(KB/s)":paging_out}

def parse_sbx_que(sbx_queue):
    """
    Parse the sandbox queue statistic result, includes submitted queue and wait for submiting queue
    Params: sandbox queue statistic result file
    Return: sandbox queue list
    Exceptions: ParseResultError
    """
    queue_num_list = []
    try:
        fd = open(sbx_queue, 'r')
        i = 1
        for lines in fd.readlines():
            items = lines.strip('')
            queue_num = int(items)
            
            queue_num_list.append([i, queue_num])
            i = i + 1
    except Exception as err:
        raise ParseResultError("Parse sandbox queue statistic fail for [%s]" % err)
    finally:
        fd.close() 
    
    return queue_num_list

if __name__=='__main__':

    import sys 
    import os
    
    ret_sum_folder = "/root/PerfTestRes/summary/"
    ret_rt_folder = "/root/PerfTestRes/realtime/" 
    ret_html_folder = "/root/PerfTestRes/htmlresult/"
    #1. parse the summary data
    try:
        #compose the file path
       # file_list = os.listdir(os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), './summary/')))
       # for file_name in file_list:
       #     if file_name.split('_')[0] == "sys":
       #         sys_sum_path = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), './summary/', file_name))
       #     elif file_name.split('_')[0] == "db":
       #         db_sum_path = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), './summary/', file_name))
        file_list = os.listdir(ret_sum_folder)
        for file_name in file_list:
            if file_name.split('_')[0] == "sys":
                sys_sum_path = ret_sum_folder + file_name
            elif file_name.split('_')[0] == "db":
                db_sum_path = ret_sum_folder + file_name 
        #parse the summary data with the specific file path
        ret = parse_summary_result(sys_sum_path, db_sum_path)
        bef_encode= {"table_tr_arr":["Email process", "System resource", "Virtual analysis", "Threat detection"], "table_tr_data":ret} 
        #dump the parse result to json format string
        sys_sum_encoded = json.dumps(bef_encode)
	
	#output the json string to system_summary.js file
        #result_js = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), './htmlresult/js/system_summary.js'))
        result_js = ret_html_folder + 'js/system_summary.js'
        if os.path.exists(result_js):
            os.remove(result_js)
        fd = open(result_js, 'a')
        fd.write("var app_sum = %s;" % sys_sum_encoded)
    except (ParseResultError, Exception), err:
        sys.exit(err)
    finally:
        if fd:
            fd.close()

    #2. parse system performance data
    try:
        #file_list = os.listdir(os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), './realtime/')))
        file_list = os.listdir(ret_rt_folder)
        for file_name in file_list:
            #file_path = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), './realtime', file_name))
            file_path = ret_rt_folder + file_name
            suffix = file_name.split('_')[0]
            if suffix == 'cpuStat':
                cpu_parse_ret = parse_sar_cpu(file_path)
            elif suffix == 'memStat':
                mem_parse_ret = parse_sar_memory(file_path)
            elif suffix == 'appdataStat':
                appdata_parse_ret = parse_sar_disk(file_path)
            elif suffix == 'rootStat':
                root_parse_ret = parse_sar_disk(file_path)
            elif suffix == 'pageStat':
                paging_parse_ret = parse_sar_page(file_path)
            elif suffix == 'sbxSubQueStat':
                sbx_sub_que_parse_ret = parse_sbx_que(file_path)
            elif suffix == 'sbxWaitQueStat':
                sbx_wait_que_parse_ret = parse_sbx_que(file_path)
    except (ParseResultError, Exception), err:
        sys.exit(err)
               
    ################################
    # output system resource usage result to file 
    ###############################
    cpu_encoded = json.dumps({"cpu":cpu_parse_ret})
    mem_encoded = json.dumps({"memory":mem_parse_ret})
    disk_encoded = json.dumps({"disk":{"AppData":appdata_parse_ret, "Root":root_parse_ret}})
    paging_encoded = json.dumps({"paging":paging_parse_ret})
    
    #output the json string to system_resource.js file
    #result_js = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), '../PerfTestRes/htmlresult/js/system_resource.js'))
    result_js = ret_html_folder + 'js/system_resource.js'
    if os.path.exists(result_js):
        os.remove(result_js)
    try:
        fd = open(result_js, 'a')
    except:
        sys.exit("Open %s fail!" % result_js)
    
    try:
        fd.write("var cpu_data = %s;\n" % cpu_encoded)
        fd.write("var mem_data = %s;\n" % mem_encoded)
        fd.write("var disk_data = %s;\n" % disk_encoded)
        fd.write("var paging_data = %s;\n" % paging_encoded)
        fd.close()
    except:
        sys.exit("Write system resource statisitc to file fail")
    finally:
        fd.close()

    ###############################
    # Output sandbox statistic result to file
    ##############################
    sbx_queue_encoded = json.dumps({"Sandbox_queue":{"Submited":sbx_sub_que_parse_ret, "To_be_submited":sbx_wait_que_parse_ret}})
    result_js = ret_html_folder + 'js/sandbox_queue.js'
    if os.path.exists(result_js):
        os.remove(result_js)
    try:
        fd = open(result_js, 'a')
    except:
        sys.exit("Open %s file fail" % result_js)

    try:
        fd.write("var sbx_que = %s;\n" % sbx_queue_encoded)
    except:
        sys.exit("Write sbx queue statistic to file fail")
    finally: 
        fd.close()

    
