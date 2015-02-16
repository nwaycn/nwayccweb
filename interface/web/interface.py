# -*-coding:utf-8 -*-
__author__ = 'lihao,18621575908'
from flask import Flask, jsonify
from flask import request
from flask import abort
from flask.ext.httpauth import HTTPBasicAuth
from flask import make_response
from ctypes import *
import time
import datetime
import numpy
import thread
import json
#from pylpccdll import *

#import pdb

api = WinDLL('Nwaycc.dll')
app = Flask(__name__)
auth = HTTPBasicAuth()
cdrlist = []
eventlist = []
eventlock = thread.allocate_lock()
cdrlock = thread.allocate_lock()
#call_event, ext_id, visitor_id,vfrom,to,caller_id,duration
NWEVENT = numpy.dtype({'names': ['call_event', 'ext_id', 'visitor_id','vfrom', 'to', 'caller_id', 'duration','create_time'],
                            'formats': ['S20','S20','S20','S20','S20','S20', 'i','S30']}, align = True)
#callid, call_type, flag_id,route,time_start,time_end, cpn, cdpn,duration,trunk_number,record_file,cdr_id
NWCDR = numpy.dtype({'names': ['callid','call_type','flag_id','route','time_start','time_end','cpn','cdpn',
                              'duration','create_time'],
                     'formats': ['i', 'S30', 'i', 'S30', 'S30', 'S30', 'S30', 'S30', 'i', 'S30']}, align = True)
NWDEVICE = numpy.dtype({'names':['id', 'otherid', 'device_type'],'formats':[ 'S30', 'S30', 'S30']}, align = True)
################################################################################

pCallBackEvent = WINFUNCTYPE(c_void_p,c_char_p, c_char_p, c_char_p ,c_char_p, c_char_p, c_char_p, c_int)
pCallBackCdr = WINFUNCTYPE(c_void_p,c_int, c_char_p, c_int, c_char_p, c_char_p,c_char_p, c_char_p,c_char_p,c_int,c_char_p,c_char_p,c_char_p)

#cal time
def timediff(timestart, timestop):
    t1 = datetime.datetime.strptime(timestart, "%Y-%m-%d %H:%M:%S")
        #datetime.datetime.fromtimestamp(time.mktime(time.strptime(timestart,"%Y-%m-%d %H:%M:%S")))
    t2 = datetime.datetime.strptime(timestop, "%Y-%m-%d %H:%M:%S")
    #datetime.datetime.datetime.datetimefromtimestamp(time.mktime(time.strptime(timestop,"%Y-%m-%d %H:%M:%S")))
    t = (t2-t1)

    return t.seconds

def getextinfo(ext_number):
    #ext_number = create_string_buffer('/0'*100)
    staffid =  '\n'*50
    mobile =  '\n'*50
    record =  '\n'*200
    voicefile =  '\n'*200
    call_direction =  '\n'*50
    state =  '\n'*50
    trunk_number =  '\n'*50
    other_leg_number =  '\n'*50
    call_state =  '\n'*50
    disturb =  '\n'*50
    api.GetExtInfo.argtypes = [c_char_p, c_char_p, c_char_p,c_char_p ,c_char_p, c_char_p, c_char_p, c_char_p, c_char_p, c_char_p, c_char_p]
    api.GetExtInfo(ext_number,  staffid,  mobile, record,  voicefile,  call_direction, state, trunk_number,  other_leg_number, call_state,  disturb)
    #print staffid,mobile,record,voicefile,call_direction,state,trunk_number,other_leg_number,call_state,disturb
    return staffid,mobile,record,voicefile,call_direction,state,trunk_number,other_leg_number,call_state,disturb

#CallDial
def callDial(call_type, ext_number, call_to_number):
    res_text = '\0'*100
    api.CallDial.argtypes = [c_ushort, c_char_p, c_char_p, c_char_p]
    #pdb.set_trace()
    myresult = api.CallDial(call_type, ext_number, call_to_number, res_text)
    return res_text

#GetDevice
def getDevice(filename):
    res_text = '\0'*100
    model = '\0'*100
    api.GetDevice.argtypes = [c_char_p, c_char_p, c_char_p]
    res = api.GetDevice(res_text, model, filename)
    return res_text,model , res

#SetDisturb
#const char* ext_id,const char* disturb,const char* lineid, char* res_text
def setDisturb(ext_id, disturb, lineid):
    res_text = '\0'*100
    api.SetDisturb.argtypes = [c_char_p, c_char_p, c_char_p, c_char_p]
    res = api.SetDisturb(ext_id,disturb, lineid, res_text)
    print res
    return res_text
def nwConnect(ipstring, port):
    api.NWConnect(ipstring,port)

def nwDisConnect():
    api.DisConnect()

def nwSetCallbackEvent(nwevent):
    api.SetEventCallBack(nwevent)

def nwSetCallbackCdr(nwcdr):
    api.SetCdrCallBack(nwcdr)
##########################################################################################

@auth.get_password
def get_password(username):
    if username == 'ok':
        return 'python'
    return None
@auth.error_handler
def unauthorized():
    return make_response(jsonify({'error': 'Unauthorized access'}), 401)

#logic coding
# curl -u ok:python -i -H "Content-Type: appliction/json" -X GET -d '{"ext_number":"8007"}' http://192.168.1.140:9033/api/v1.0/get_ext_info

@app.route('/api/v1.0/get_ext_info', methods=['GET'])
@auth.login_required
def GetExtInfo():
    if not request.json or not 'ext_number' in request.json:
        abort(400)
    ext_number = request.json['ext_number']
    staffid,mobile,record,voicefile,call_direction,state,trunk_number,other_leg_number,call_state,disturb = getextinfo(ext_number)
    ext_info = {
        'ext_number':ext_number.strip(),
        'staffid': staffid.strip(),
        'mobile': mobile.strip(),
        'record': record.strip(),
        'voicefile': voicefile.strip(),
        'call_direction': call_direction.strip(),
        'state': state.strip(),
        'trunk_number': trunk_number.strip(),
        'other_leg_number': other_leg_number.strip(),
        'call_state': call_state.strip(),
        'disturb': disturb.strip()
    }
    return jsonify({'ext_info': ext_info}), 201


#  curl -u ok:python -i -H "Content-Type: application/jso" -X POST -d '{"ext_number":"8007","call_to_number":"18621575908"}' http://192.168.1.140:9033/api/v1.0/call_dial

@app.route('/api/v1.0/call_dial', methods=['POST'])
@auth.login_required
def call_Dial():
    print request.json

    if not request.json or not 'ext_number' in request.json :
        abort(400)
    ext_number = request.json['ext_number']
    call_to_number = request.json['call_to_number']
    try:
        res_text = callDial(1, ext_number, call_to_number)
    except Exception,ex:
        return jsonify({'except':ex.message}), 500
    return jsonify({'res_text':res_text}), 201

#  curl -u ok:python -i -H "Content-Type: application/json" -X GET http://192.168.1.140:9033/api/v1.0/events
@app.route('/api/v1.0/events', methods=['GET'])
@auth.login_required
def get_events():
    global eventlock,eventlist

    eventlock.acquire()

    mylist = []

    for event in eventlist:
        myevent = {
            'call_event':event['call_event'][0],
            'ext_id':event['ext_id'][0],
            'visitor_id':event['visitor_id'][0],
            'vfrom':event['vfrom'][0],
            'to':event['to'][0],
            'caller_id':event['caller_id'][0],
            'duration':event['duration'][0]
        }
        mylist.append(myevent)
    eventlist = []

    eventlock.release()
    return jsonify({'call_events':mylist}),201

# curl -u ok:python -i -H "Content-Type: application/jsn" -X GET http://192.168.1.140:9033/api/v1.0/cdrs
@app.route('/api/v1.0/cdrs', methods=['GET'])
@auth.login_required
def get_cdrs():
    global  cdrlock,cdrlist
    cdrlock.acquire()
    mylist = []

    for cdr in cdrlist:
        mycdr = {
            'callid':cdr['callid'][0],
            'call_type':cdr['call_type'][0],
            'flag_id': cdr['flag_id'][0],
            'route':cdr['route'][0],
            'time_start': cdr['time_start'][0],
            'time_end':cdr['time_end'][0],
            'cpn':cdr['cpn'][0],
            'cdpn':cdr['cdpn'][0],
            'duration':cdr['duration'][0],
            'create_time':cdr['create_time'][0]
        }
        mylist.append(mycdr)
    cdrlist = []
    cdrlock.release()
    return jsonify({'call_cdrs':mylist}),201

#  curl -u ok:python -i -H "Content-Type: application/json" -X GET http://192.168.1.140:9033/api/v1.0/devices
@app.route('/api/v1.0/devices', methods=['GET'])
@auth.login_required
def get_devices():
    res_text,model , res = getDevice('nwaydevice.txt')
    arr = []
    if res == 0:
        #parse the txt file
        filehandle = open('nwaydevice.txt')
        filelines = filehandle.readlines()
        for fileli in filelines:
            arr.append(fileli)
        return jsonify({'model':model,'devices':arr}),201
    else:
        return jsonify({'error':res_text}),201

# curl -u ok:python -i -H "Content-Type: application/json" -X POST -d '{"ext_number":"8006","disturb":"on","lineid":"phone 7"}' http://192.168.1.140:9033/api/v1.0/disturb
@app.route('/api/v1.0/disturb', methods=['POST'])
@auth.login_required
def set_disturb():
    if not request.json or not 'ext_number' in request.json or not 'disturb' in request.json or not 'lineid' in request.json:
        abort(400)
    ext_id = request.json['ext_number']
    disturb = request.json['disturb']
    lineid = request.json['lineid']
    res = setDisturb(ext_id,disturb,lineid)
    #print res
    return jsonify({'result':'ok'}) ,201


#call back
def nwCallBackEvent(call_event, ext_id, visitor_id,vfrom,to,caller_id,duration):
    #print call_event, ext_id, visitor_id,vfrom,to,caller_id,duration
    global eventlock,eventlist
    v_call_event = call_event
    v_ext_id = ext_id
    v_visitor_id= visitor_id
    v_from=vfrom
    v_to=to
    v_caller_id= caller_id
    v_duration = duration
    nowtime =str(datetime.datetime.now())[:19]
    eventlock.acquire()
    nwevent = numpy.array([(v_call_event, v_ext_id, v_visitor_id,v_from,v_to,v_caller_id,v_duration,nowtime)], dtype= NWEVENT)
    eventlist.append(nwevent)
    #remove nowtime morethan 5minitues
    listlen = len(eventlist)
    #print "the list length"
    #print listlen
    for event in eventlist:
        #print event
        lasttime = event["create_time"][0]
        #print lasttime
        counttime =  timediff(lasttime,nowtime)
        if counttime > 300 :
            #eventlist.remove(event)
            del event
    eventlock.release()


def nwCallBackCdr(callid, call_type, flag_id,route,time_start,time_end, cpn, cdpn,duration,trunk_number,record_file,cdr_id):
    #print callid, call_type, flag_id,route,time_start,time_end, cpn, cdpn,duration,trunk_number,record_file,cdr_id
    #print 'cdr'
    global cdrlock,cdrlist
    cdrlock.acquire()
    nowtime =str(datetime.datetime.now())[:19]
    nwcdr = numpy.array([(callid,call_type, flag_id,route,time_start,time_end, cpn, cdpn,duration,nowtime)],dtype=NWCDR);
    cdrlist.append(nwcdr)
    for cdr in cdrlist:
        lasttime = cdr["create_time"][0]
        counttime =  timediff(lasttime,nowtime)
        if counttime > 300 :
            #cdrlist.remove(cdr)
            del cdr
    cdrlock.release()


if __name__ == '__main__':

    nwConnect("127.0.0.1", 9020)
    #load Call back event about call
    pCallBackEventhandle = pCallBackEvent(nwCallBackEvent)
    nwSetCallbackEvent(pCallBackEventhandle)
    #load Callback cdr
    pCallbackCdrHandle = pCallBackCdr(nwCallBackCdr)
    nwSetCallbackCdr(pCallbackCdrHandle)

    app.run(debug=True, host='0.0.0.0', port=9033)
