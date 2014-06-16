#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import os
import random
import time
import email as em
from email.Message import Message
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email import encoders

def prepare_url(formalized_url):
    """
    Extract the URLs
    """
    url_sha1_sum = []
    sha1_url_pair = {}
    try:
        fp = open(formalized_url,'r')
    except Exception as err:
        print "Formalized URL file doesn't exist for [%s]" % err
        sys.exit()
    
    try:
        for line in fp.readlines():
            sha1 = line.split('-')[0]
            url = line.split('-')[1].strip('\n')
            url_sha1_sum.append(sha1)
            sha1_url_pair[sha1] = url
    except Exception as err:
        print "Extract the URLs fail for [%s]" % err
    finally:
        fp.close()
    #Random url sha1 list 
    random.shuffle(url_sha1_sum)
    return url_sha1_sum, sha1_url_pair


def modify_eml(old_eml_file_list, url_sha1_list, url_sha1_dict):
    """
    Update the eml content to add URLs
    """
    i = 0
    flag = True
    j = 0
    count = 0
    tmp_url = ''

    for sha1 in url_sha1_list:
        tmp_url = tmp_url + url_sha1_dict[sha1] + '\n'   # Construct the URLs
        if i == 2:
            try:
                fp = open(old_eml_file_list[j], 'r')
            except Exception as err:
                print "Read message fail for %s" % err
                raise

            msg = em.message_from_file(fp)
            fp.close()

            # Modify the eml body
            if msg.is_multipart():
                # email has multiple parts
                ret_msg = modify_multipart_eml(old_eml_file_list[j], tmp_url)
            else:
                # email hasn't multiple parts
                ret_msg = modify_nonmultipart_eml(old_eml_file_list[j], tmp_url)

            # Write to a new email
            new_eml = '/home/develop/backup/email/samples/10Per_with_mal_aft_mod/' + os.path.basename(old_eml_file_list[j])
            fp = open(new_eml, 'wb')
            fp.write(ret_msg.as_string())
            fp.close()

            # Re-initialize the variables
            i = 0
            j = j + 1
            tmp_url = ''
        else:
            i = i + 1
            continue


def modify_multipart_eml(old_eml_file, url_str):
    fp = open(old_eml_file, 'r')
    msg = em.message_from_file(fp)
    fp.close()
    
    # modify the exist text/html part to remove lable <a>
    for part in msg.get_payload():
        if part.get_content_type() == 'text/html':
            part.set_payload('<html><head></head><body><p>Hi!<br>How are you?<br>Here is the link you wanted.</p></body></html>')
            encoders.encode_base64(part)
            break
    
    # Add a new message part
    sub_part = MIMEText(url_str, 'plain')
    msg.attach(sub_part)
    
    return msg



def modify_nonmultipart_eml(old_eml_file, url_str):
    fp = open(old_eml_file, 'r')
    msg = em.message_from_file(fp)
    fp.close()
    """
    Back up the headers
    """
    header_dict = msg.items()
    payload = msg.get_payload()

    """
    Create a multipart message
    """
    new_mail = MIMEMultipart('alternative')
    for key in msg.keys():
        new_mail[key] = msg[key]

    """Create a MIMEtext sub message
    """
    sub_part_1 = MIMEText(payload, 'plain')
    sub_part_2 = MIMEText(url_str, 'plain')

    """
    Build up the whole email
    """
    new_mail.attach(sub_part_2)
    new_mail.attach(sub_part_1)
    
    return new_mail

if __name__ == '__main__':
    """
    Extract eml files
    """
    eml_list = []
    for file in os.listdir('/home/develop/backup/email/samples/10Per_with_mal/'):
        eml_list.append('/home/develop/backup/email/samples/10Per_with_mal/' + file)
    
    tmp_url_sha1_list, tmp_url_sha1_dict = prepare_url('/home/develop/backup/email/samples/formalized_url')
    #eml_list = [
    #            '/home/develop/backup/email/samples/3bc5bfdc41cfad2a5b701861ac53f24c.eml',
    #            '/home/develop/backup/email/samples/3db73cb1d36c1b23a04c84a5fcf054b6.eml',
    #            '/home/develop/backup/email/samples/74886e8fa2f36394af896da2bf85c3e439.eml',
    #            '/home/develop/backup/email/samples/ca987297b59168cce689368d30bb473b.eml'
    #           ]
    try:
        modify_eml(eml_list, tmp_url_sha1_list, tmp_url_sha1_dict)
    except:
        sys.exit()
