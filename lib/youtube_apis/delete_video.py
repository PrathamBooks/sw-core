#!/usr/bin/python

import httplib2
import os
import sys
import argparse

from apiclient.discovery import build
from apiclient.errors import HttpError
from oauth2client.client import flow_from_clientsecrets
from oauth2client.file import Storage
from oauth2client.tools import argparser, run_flow
from oauth_util import get_authenticated_service


def delete_video(youtube, args):
 # print youtube.videos()#.list(id="crgnWi1z7AI",part="snippet,status")
  # Call the API's videos.list method to retrieve the video resource.
  videos_list_response = youtube.videos().list(
    id=args.video_id,
    part='snippet,status'
  ).execute()

  print videos_list_response
  # If the response does not contain an array of 'items' then the video was
  # not found.
  if not videos_list_response['items']:
    print 'Video "%s" was not found.' % args.video_id
    sys.exit(1)

  # Update the video resource by calling the videos.update() method.
  videos_update_response = youtube.videos().delete(
      id=args.video_id
    ).execute()
  print videos_update_response


if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('--video_id', help='ID of video to delete.',
    required=True)
  parser.add_argument("--language", help="Video language, english | hindi", required=True)
  args = parser.parse_args()
  youtube = get_authenticated_service(args)
  try:
    delete_video(youtube, args)
  except HttpError, e:
    print 'An HTTP error %d occurred:\n%s' % (e.resp.status, e.content)
    print 'Tag "%s" was added to video id "%s".' % (args.add_tag, args.video_id)
                                                                                   
