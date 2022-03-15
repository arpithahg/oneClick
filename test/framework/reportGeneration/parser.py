
import sys
import os,glob
import globalVariables
from flask import Flask, render_template
app = Flask(__name__,template_folder='templates')

def parseResults():
    print ("Number of arguments:", len(sys.argv), 'arguments.')
    print ("log folder path", sys.argv[1])
    logpath= sys.argv[1]

    for filename in os.listdir(logpath):
        print("parsing the file", os.path.join(logpath, filename))
        # for filename1 in glob.glob(os.path.join(logpath,filename)):
        with open(glob.glob(os.path.join(logpath,filename))[0], 'r') as f:
            text = f.read()
            justName = filename.split(".")[0]
            if "exit status 1" in text:
                status = "FAIL"
            else:
                status = "PASS"
            globalVariables.parsedReportDict[justName] = [status, text]
    print(globalVariables.parsedReportDict)

@app.route('/')
def index():
    return render_template('index2.html', variable=globalVariables.parsedReportDict)

if __name__ == '__main__':
    parseResults()
    os.chdir('reportGeneration/')
    print(os.getcwd())
    app.run()


