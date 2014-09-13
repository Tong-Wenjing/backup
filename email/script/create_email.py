#!/usr/bin/env python
#-*- coding: utf-8 -*-

#System modules
import os
import sys
import exceptions

#################
#For guessing MIME type based on file name extension
import mimetypes

#################
# For parse input parameters
import argparse

################
# For email generation
from email import encoders
from email.message import Message
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.mime.audio import MIMEAudio
from email.mime.image import MIMEImage
from email.mime.message import MIMEMessage
from email.mime.text import MIMEText

#Custom modules
# N/A

# Global Variables
COMMASPACE = ','

class createEmailError(Exception):
    pass

def cli_parser():
    """
    Create the parameters which would be used by this script
    Params: None
    Return: argparse object
    Exception: None
    """
    parser = argparse.ArgumentParser(prog='CreateEmail',
                                     description='This script is used for generating an email with .eml extension')
    parser.add_argument('-d', '--directory', action='store', dest='directory',
                        help="Mail the contents of the specified directory, \
                              otherwise use the current directory. \
                              Only the regular files in the directory are sent, \
                              and we don't recurse to subdirectories.")
    parser.add_argument('-o', '--output', action='store', dest='output', required=True, 
                        help="Print the composed message to FILE instead of \
                              sending the message to the SMTP server. This option is required.")
    parser.add_argument('-a', '--attachment', action='store', dest='attachment', 
                        help="Attach an attachment to the email. \
                              Should be followed by an attachment absoluted path. \
                              if you want to attach a batch of attachments, use '-d' or '--directory' instead")
    parser.add_argument('-u', '--url', action='store', dest='url', 
                        help="Append URL(s) to the email. Should be followed by a text file with URL(s)")
    parser.add_argument('-s', '--sender', action='store', default='sender@test.com', dest='sender', 
                        help="Specify an email sender. If not, use default sender@test.com")
    parser.add_argument('-r', '--recipient', action='append', default=['receiver@test.com'], dest='recipients', 
                        help="Specify the email recipient(s). Can be multiple recipients separated by ';' \
                              if not, use default receiver@test.com")
    parser.add_argument('-j', '--subject', action='store', default='test', dest='subject', 
                        help="Specify the email subject. If not, use default 'test'")

    return parser

def create_sub_msg(attachment_path):

    attachment_name = os.path.basename(attachment_path)
    #Guess the content type based on the file's extension.  Encoding
    # will be ignored, although we should check for simple things like
    # gzip'd or compressed files.
    mime_type, encoding = mimetypes.guess_type(attachment_path)
    if mime_type is None or encoding is not None:
        # No guess could be made, or the file is encoded (compressed), so
        # use a generic bag-of-bits type.
        mime_type = 'application/octet-stream'
    main_type, sub_type = mime_type.split('/', 1)
    if main_type == 'text':
        fp = open(attachment_path)
        submsg = MIMEText(fp.read(), _subtype=sub_type)
        fp.close()
    if main_type == 'image':
        fp = open(attachment_path, 'rb')
        submsg = MIMEImage(fp.read(), _subtype=sub_type)
        fp.close()
    if main_type == 'audio':
        fp = open(attachment_path, 'rb')
        submsg = MIMEAudio(fp.read(), _subtype=sub_type)
        fp.close()
    else:
        fp = open(attachment_path, 'rb')
        submsg = MIMEBase(main_type, sub_type)
        submsg.set_payload(fp.read())
        fp.close()
        # Encode the payload with Base64
        encoders.encode_base64(submsg)
    submsg.add_header('Content-Disposition', 'attachment', filename=attachment_name)

    return submsg


def main():
    """
    Main entry of generate an email.
    1. Parse input parameters
    2. Compose the sub message objects
        1) Create the outmost enclosing message object
        2) Guess attachment file MIME type
        3) Create MIME sub message objects based on MIME type
        4) Compose the sub message objects 
    3. Output the composed message object to file
    """
    # Local variables
    sender = ''
    recipients = []
    subject = ''
    attach_dir = ''
    attach_file = ''
    url_file = ''
    output = ''

    # Initial option parser
    parser = cli_parser()
    # Parse out the options
    args = parser.parse_args()

    ###########################################################################
    # Parse input parameters
    ###########################################################################
    # 1. Parse sender
    sender = args.sender
    # 2. Parse recipient
    recipients = args.recipients
    # 3. Parse subject
    subject = args.subject
    # 4. Parse Attachment Directory or singl ATTACHMENT
    if args.directory:      # use attachment in a directory
        attach_dir = args.directory
    elif args.attachment:   # otherwise use a single attachment
        attach_file = args.attachment
    # 5. Parse URLs
    if args.url:
        url_file = args.url
    # 6. Parse output file
    output = args.output

    ###########################################################################
    # Compose the sub message objects
    ###########################################################################
    # 1. Create the outmost encoling message object
    outer_msg = MIMEMultipart()
    outer_msg['Subject'] = subject
    outer_msg['To'] = COMMASPACE.join(recipients)
    outer_msg['From'] = sender

    # Directory option specified
    if attach_dir:
        if not os.path.isdir(attach_dir):
            print "%s is not a directory." % attach_dir
            sys.exit(1)
        for filename in os.listdir(attach_dir):
            file = os.path.join(attach_dir, filename)
            if not os.path.isfile(file):
                continue
            submsg = create_sub_msg(file)
            # attach sub message to outmost message
            outer_msg.attach(submsg)

    # Attachment option specified
    if attach_file:
        if not os.path.isfile(attach_file):
            print "%s is not a file." % attach_file
            sys.exit(1)
        submsg = create_sub_msg(attach_file) 
        # attach sub message to outmost message
        outer_msg.attach(submsg)

    # URL option specified
    if url_file:
        if not os.path.isfile(url_file):
            print "%s is not a file or cannot be found." % url_file
            sys.exit(1)
        fp = open(url_file, 'r')
        submsg = MIMEText(fp.read())
        fp.close()
        outer_msg.attach(submsg)

    ##########################################################################
    # Output the composed message object to file
    ##########################################################################
    try:
        fp = open(output, 'w')
    except Exception as err:
        raise createEmailError("The output file cannot be opened for [%s]" % err)
    try: 
        fp.write(outer_msg.as_string())
    except Exception as err:
        raise createEmailError("The output file cannot be written for [%s]" % err)
    finally:
        fp.close()

if __name__ == '__main__':
    try:
        main()
    except (createEmailError, Exception) as err:
        print err
