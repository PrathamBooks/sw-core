import argparse
import tempfile

parser = argparse.ArgumentParser(description='Generate alignment tags using aeneas')
parser.add_argument('--txt',
                    required=True,
                    help='txt file')

parser.add_argument('--audio',
                    required=True,
                    help='audio file')

parser.add_argument('--out',
                    required=True,
                    help='output file')

parser.add_argument('--lang',
                    help='eng for english, hi for Hindi')

parser.add_argument('--args',
                    help='eng for english, hi for Hindi')

args = parser.parse_args()
lang = u"eng"

if args.lang:
    lang = args.lang

if lang not in ["eng", "hi", "hin"]:
    print("only hi and eng allowed for language")
    exit(1)

from aeneas.executetask import ExecuteTask
from aeneas.task import Task
from aeneas.runtimeconfiguration import RuntimeConfiguration

config_string = u"task_language=" + lang + u"|is_text_type=subtitles|os_task_file_format=srt"

tempout, tempfilename = tempfile.mkstemp()
task = Task(config_string=config_string)
task.audio_file_path_absolute = args.audio
task.text_file_path_absolute = args.txt
task.sync_map_file_path_absolute = tempfilename
rconf = RuntimeConfiguration()
# This option ignores the non-word sounds in the audio
rconf[RuntimeConfiguration.MFCC_MASK_NONSPEECH] = True
rconf[RuntimeConfiguration.MFCC_MASK_LOG_ENERGY_THRESHOLD] = 2.5

# To use a different Text-to-Speech engine
#rconf[RuntimeConfiguration.TTS] = "festival"

# process Task
ExecuteTask(task, rconf=rconf).execute()

# output sync map to file
task.output_sync_map_file()

f = open(args.out, "w")
f.writelines("WEBVTT\n")
f.writelines("\n")

with open(tempfilename, 'rU') as tempout:
    for l in tempout:
        f.writelines(l.replace(",", "."))

f.close()
