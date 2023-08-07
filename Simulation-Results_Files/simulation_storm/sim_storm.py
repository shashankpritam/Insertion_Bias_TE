import argparse
import random
import time
import math
import os
import subprocess

jls_extract_var = os.path.join("/Users", "shashankpritam", "github", "invadego-insertionbias", "main")
invade_path = jls_extract_var

parser = argparse.ArgumentParser(description="""           
Description
-----------
    Simulation Storm""",
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog="""
Prerequisites
-------------
    python version 3+

Authors
-------
    Robert Kofler
    Filip Wierzbicki
    Almorò Scarpa
    Shashank Pritam
""")


def current_milli_time():
    return round(time.time() * 1000)

def get_rand_bias():
    return random.randint(-100, 100)

def get_basis(invade):
    return f'{invade} -no-x-cluins --N 1000 --gen 5000 --genome mb:10,10,10,10,10 --x 0.01 --rr 4,4,4,4,4 --rep 1 --u 0.2 --steps 5000 --silent'

def get_filter():
    return """|grep -v "^Invade"|grep -v "^#" """

def get_rand_clusters():
    r = math.floor(10**random.uniform(3.69899,5.69899))
    return f"{r},{r},{r},{r},{r}"

def run_cluster_negsel(invade, count, output):
    """
    TE invasion that is stopped by cluster insertions and neg selection against TEs
    """
    commandlist = []
    for i in range(count):
        x = get_rand_clusters()
        tr = current_milli_time() + i
        command_basis = get_basis(invade)
        command = f'{command_basis} --basepop "100({get_rand_bias()})" --cluster bp:{x} --replicate-offset {i} --seed {tr} '
        command += f'--sampleid "{x}"  {get_filter()} > {os.path.join(output, str(i))}.txt'
        commandlist.append(command)
    return commandlist

def get_default_output_directory():
    current_time = time.strftime("%dth%b%yat%I%M%p", time.gmtime())
    return os.path.join("/Users", "shashankpritam", "github", "Insertion-Bias-TE", "Simulation-Results_Files", "simulation_storm", current_time)


parser = argparse.ArgumentParser()
parser.add_argument("--number", type=int, dest="count", default=100, help="the number of simulations")
parser.add_argument("--threads", type=int, dest="threads", default=4, help="the threads of simulations")
parser.add_argument("--output", type=str, dest="output", default=get_default_output_directory(), help="the output directory for simulations")
parser.add_argument("--invade", type=str, dest="invade", default=invade_path, help="the invade.go")
parser.add_argument("--silent", action="store_true", dest="silent", default=False, help="be quiet; default=False")

args = parser.parse_args()

# Create the default output directory if it doesn't exist
if not os.path.exists(args.output):
    os.makedirs(args.output)

# Construct the command list
commandlist = run_cluster_negsel(args.invade, args.count, args.output)

print(commandlist)

def submit_job_max_len(commandlist, max_processes):
    import subprocess
    sleep_time = 10.0
    processes = list()
    for command in commandlist:
        if not args.silent:
            print(f'running {len(processes)} processes. Submitting {command}')
        processes.append(subprocess.Popen(command, shell=True, stdout=None))
        while len(processes) >= max_processes:
            time.sleep(sleep_time)
            processes = [proc for proc in processes if proc.poll() is None]
    while len(processes) > 0:
        time.sleep(sleep_time)
        processes = [proc for proc in processes if proc.poll() is None]
 
#submit_job_max_len(commandlist, max_processes=args.threads)
print("Done")

