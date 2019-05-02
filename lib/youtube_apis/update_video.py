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


def update_video(youtube, args):
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

  # Since the request specified a video ID, the response only contains one
  # video resource. This code extracts the snippet from that resource.
  videos_list_snippet = videos_list_response['items'][0]['snippet']
  videos_list_status = videos_list_response['items'][0]['status']
  # Set video title, description, default language if specified in args.
  if args.title:
    videos_list_snippet['title'] = args.title
  if args.description:
    videos_list_snippet['description'] = args.description
  if args.privacyStatus:
    videos_list_status['privacyStatus'] = args.privacyStatus
  # Preserve any tags already associated with the video. If the video does
  # not have any tags, create a new array. Append the provided tag to the
  # list of tags associated with the video.
  if 'tags' not in  videos_list_snippet:
    videos_list_snippet['tags'] = []
  if args.tags:
    videos_list_snippet['tags'] = args.tags.split(',')
  elif args.add_tag:
    videos_list_snippet['tags'].append(args.add_tag)

  print(videos_list_snippet);

  # Update the video resource by calling the videos.update() method.
  videos_update_response = youtube.videos().update(
    part='snippet,status',
    body=dict(
      snippet=videos_list_snippet,
      status=videos_list_status,
      id=args.video_id
    )).execute()
  print videos_update_response
  print('The updated video metadata is:\n' +
        'Title: ' + videos_update_response['snippet']['title'] + '\n')
  if videos_update_response['snippet']['description']:
    print ('Description: ' +
           videos_update_response['snippet']['description'] + '\n')
  if videos_update_response['status']['privacyStatus']:
    print ('Status: ' +
           videos_update_response['status']['privacyStatus'] + '\n')
  if videos_update_response['snippet']['tags']:
    print ('Tags: ' + ','.join(videos_update_response['snippet']['tags']) + '\n')

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('--video_id', help='ID of video to update.',
    required=True)
  parser.add_argument('--tags',
    help='Comma-separated list of tags relevant to the video. This argument ' +
         'replaces the existing list of tags.')
  parser.add_argument('--add_tag', help='Additional tag to add to video. ' +
      'This argument does not affect current tags.')
  parser.add_argument('--title', help='Title of the video.')
  parser.add_argument('--description', help='Description of the video.')
  parser.add_argument("--language", help="Video language, english | hindi", required=True)
  parser.add_argument('--privacyStatus', help='Status of the video.')
  args = parser.parse_args()
  youtube = get_authenticated_service(args)
  try:
    update_video(youtube, args)
  except HttpError, e:
    print 'An HTTP error %d occurred:\n%s' % (e.resp.status, e.content)
    print 'Tag "%s" was added to video id "%s".' % (args.add_tag, args.video_id)
