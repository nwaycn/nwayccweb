
--http://www.nway.com.cn
--上海宁卫信息技术有限公司版权所有
-- Table: call_after_opt

-- DROP TABLE call_after_opt;

CREATE TABLE call_after_opt
(
  id integer NOT NULL,
  name character varying(50) NOT NULL,
  CONSTRAINT call_after_opt_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_after_opt
  OWNER TO postgres;
COMMENT ON TABLE call_after_opt
  IS '在外呼时，播放铃声后操作';

-- Table: call_base_config

-- DROP TABLE call_base_config;

CREATE TABLE call_base_config
(
  id integer NOT NULL,
  config_name character varying(255) NOT NULL,
  config_param character varying(255) NOT NULL,
  CONSTRAINT call_base_config_pkey PRIMARY KEY (id, config_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_base_config
  OWNER TO postgres;

-- Table: call_cdr

-- DROP TABLE call_cdr;

CREATE TABLE call_cdr
(
  id bigserial NOT NULL,
  accountcode text,
  xml_cdr text,
  caller_id_name character varying(50),
  caller_id_number character varying(50),
  destination_number character varying(50),
  star_epoch numeric,
  start_stamp timestamp without time zone,
  a_answer_stamp timestamp without time zone,
  a_answer_epoch numeric,
  a_end_epoch numeric,
  a_end_stamp timestamp without time zone,
  duration numeric,
  mduration numeric,
  billsec numeric,
  recording_file character varying(255),
  conference_name character varying(50),
  conference_id bigint,
  digites_dialed character varying(50),
  hangup_cause character varying(200),
  hangup_cause_id bigint,
  waitsec integer,
  call_gateway_id bigint,
  b_answer_stamp timestamp without time zone,
  b_answer_epoch numeric,
  b_end_stamp timestamp without time zone,
  b_end_epoch numeric,
  hangup_direction integer, -- 挂机方向，和c部分的对应
  a_leg_called boolean DEFAULT false, -- a leg接通
  b_leg_called boolean DEFAULT false,
  called_number character varying(50),
  auto_callout boolean DEFAULT false,
  CONSTRAINT "PK_CALL_CDR_ID" PRIMARY KEY (id),
  CONSTRAINT "FK_CALL_CDR_GATEWAY_ID" FOREIGN KEY (call_gateway_id)
      REFERENCES call_gateway (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_CDR_HANGUP_CAUSE_ID" FOREIGN KEY (hangup_cause_id)
      REFERENCES call_hangup_cause (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_cdr
  OWNER TO postgres;
COMMENT ON COLUMN call_cdr.hangup_direction IS '挂机方向，和c部分的对应';
COMMENT ON COLUMN call_cdr.a_leg_called IS 'a leg接通';


-- Index: "IDX_CDR_MAIN"

-- DROP INDEX "IDX_CDR_MAIN";

CREATE INDEX "IDX_CDR_MAIN"
  ON call_cdr
  USING btree
  (id, caller_id_name COLLATE pg_catalog."default", caller_id_number COLLATE pg_catalog."default", destination_number COLLATE pg_catalog."default", start_stamp, a_answer_stamp, a_end_stamp, hangup_cause_id, call_gateway_id);

-- Table: call_click_dial

-- DROP TABLE call_click_dial;

CREATE TABLE call_click_dial
(
  id bigserial NOT NULL,
  caller_number character(50), -- 客户电话，如手机号，不管3721都加0
  is_agent boolean DEFAULT false, -- 是否属于voip内线
  is_immediately boolean DEFAULT false, -- 是否立即执行
  trans_number character varying(50), -- 转接号码
  time_plan timestamp without time zone, -- 当is_immediately为FALSE时生效，定时呼叫
  account_number character varying(50), -- 计费帐户
  is_called boolean DEFAULT false, -- 是否呼叫
  CONSTRAINT call_click_dial_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_click_dial
  OWNER TO postgres;
COMMENT ON COLUMN call_click_dial.caller_number IS '客户电话，如手机号，不管3721都加0';
COMMENT ON COLUMN call_click_dial.is_agent IS '是否属于voip内线';
COMMENT ON COLUMN call_click_dial.is_immediately IS '是否立即执行';
COMMENT ON COLUMN call_click_dial.trans_number IS '转接号码';
COMMENT ON COLUMN call_click_dial.time_plan IS '当is_immediately为FALSE时生效，定时呼叫';
COMMENT ON COLUMN call_click_dial.account_number IS '计费帐户';
COMMENT ON COLUMN call_click_dial.is_called IS '是否呼叫';


-- Index: "IDX_CLICK_DIAL"

-- DROP INDEX "IDX_CLICK_DIAL";

CREATE INDEX "IDX_CLICK_DIAL"
  ON call_click_dial
  USING btree
  (id, caller_number COLLATE pg_catalog."default", is_agent, is_immediately, account_number COLLATE pg_catalog."default", is_called, trans_number COLLATE pg_catalog."default");

-- Table: call_concurr_type

-- DROP TABLE call_concurr_type;

CREATE TABLE call_concurr_type
(
  id bigint NOT NULL,
  concurr_type_name character varying(255) NOT NULL,
  CONSTRAINT call_concurr_type_pkey PRIMARY KEY (id, concurr_type_name)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_concurr_type
  OWNER TO postgres;
COMMENT ON TABLE call_concurr_type
  IS '并发类型';
-- Table: call_dialplan_details

-- DROP TABLE call_dialplan_details;

CREATE TABLE call_dialplan_details
(
  id bigserial NOT NULL,
  dialplan_id bigint,
  dialplan_detail_tag character varying(255),
  dialplan_detail_data text,
  dialplan_detail_inline text,
  dialplan_detail_group_id bigint,
  dialplan_detail_order integer,
  dialplan_detail_break boolean,
  dialplan_detail_type_id integer,
  ring_id bigint DEFAULT 0, -- 如果是播放彩铃，则需要彩铃id
  CONSTRAINT call_dialplan_details_pkey PRIMARY KEY (id),
  CONSTRAINT "FK_DIALPLAN_DETAILS_DIALPLAN_ID" FOREIGN KEY (dialplan_id)
      REFERENCES call_dialplans (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_DIALPLAN_DETAILS_GROUP_ID" FOREIGN KEY (dialplan_detail_group_id)
      REFERENCES call_extension_groups (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_DIALPLAN_DETAILS_OPERATION_ID" FOREIGN KEY (dialplan_detail_type_id)
      REFERENCES call_operation (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_DIALPLAN_DETAILS_RING_ID" FOREIGN KEY (ring_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_dialplan_details
  OWNER TO postgres;
COMMENT ON COLUMN call_dialplan_details.ring_id IS '如果是播放彩铃，则需要彩铃id';


-- Index: "IDX_CALL_DIALPLAN_DETAILS_MAIN"

-- DROP INDEX "IDX_CALL_DIALPLAN_DETAILS_MAIN";

CREATE INDEX "IDX_CALL_DIALPLAN_DETAILS_MAIN"
  ON call_dialplan_details
  USING btree
  (id, dialplan_id);

-- Table: call_dialplans

-- DROP TABLE call_dialplans;

CREATE TABLE call_dialplans
(
  id bigserial NOT NULL,
  dialplan_name character varying(255), -- 名称
  dialplan_context character varying(255), -- 一般destination_number即可
  dialplan_number character varying(255), -- 号码，可按正则表达式来
  dialplan_order numeric,
  dialplan_description text,
  dialplan_enabled boolean,
  dialplan_continue boolean,
  CONSTRAINT call_dialplans_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_dialplans
  OWNER TO postgres;
COMMENT ON COLUMN call_dialplans.dialplan_name IS '名称';
COMMENT ON COLUMN call_dialplans.dialplan_context IS '一般destination_number即可';
COMMENT ON COLUMN call_dialplans.dialplan_number IS '号码，可按正则表达式来';

-- Table: call_extension

-- DROP TABLE call_extension;

CREATE TABLE call_extension
(
  id bigserial NOT NULL,
  extension_name character varying(50) NOT NULL, -- 分机名称
  extension_number character varying(50) NOT NULL, -- 分机号码
  callout_number character varying(50), -- 外呼时的号码
  extension_type bigint, -- 分机类型
  group_id bigint,
  extension_pswd character varying(130),
  extension_login_state character varying(50) DEFAULT 'success'::character varying,
  extension_reg_state character varying(50), -- 注册状态
  callout_gateway bigint,
  is_allow_callout boolean,
  call_state integer, -- 该分机的通话状态，空闲为0，正在通话中1
  CONSTRAINT "PK_EXTENSION_ID" PRIMARY KEY (id),
  CONSTRAINT "FK_EXTENSION_GATEWAY_ID" FOREIGN KEY (callout_gateway)
      REFERENCES call_gateway (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_EXTENSION_GROUP_ID" FOREIGN KEY (group_id)
      REFERENCES call_group (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_EXTENSION_TYPE_ID" FOREIGN KEY (extension_type)
      REFERENCES call_extension_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_extension
  OWNER TO postgres;
COMMENT ON COLUMN call_extension.extension_name IS '分机名称';
COMMENT ON COLUMN call_extension.extension_number IS '分机号码';
COMMENT ON COLUMN call_extension.callout_number IS '外呼时的号码';
COMMENT ON COLUMN call_extension.extension_type IS '分机类型';
COMMENT ON COLUMN call_extension.extension_reg_state IS '注册状态';
COMMENT ON COLUMN call_extension.call_state IS '该分机的通话状态，空闲为0，正在通话中1';

-- Table: call_extension_groups

-- DROP TABLE call_extension_groups;

CREATE TABLE call_extension_groups
(
  id bigserial NOT NULL,
  group_name character varying(255) NOT NULL, -- 分机组名称
  group_description character varying(500),
  CONSTRAINT call_extension_groups_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_extension_groups
  OWNER TO postgres;
COMMENT ON COLUMN call_extension_groups.group_name IS '分机组名称';


-- Index: "IDX_CALL_EXTENSION_GROUPS_MAIN"

-- DROP INDEX "IDX_CALL_EXTENSION_GROUPS_MAIN";

CREATE INDEX "IDX_CALL_EXTENSION_GROUPS_MAIN"
  ON call_extension_groups
  USING btree
  (id, group_name COLLATE pg_catalog."default");

-- Table: call_extension_type

-- DROP TABLE call_extension_type;

CREATE TABLE call_extension_type
(
  id bigserial NOT NULL,
  type_name character varying(50),
  CONSTRAINT "PK_EXTENSION_TYPE_ID" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_extension_type
  OWNER TO postgres;
-- Table: call_functions

-- DROP TABLE call_functions;

CREATE TABLE call_functions
(
  id bigint NOT NULL,
  function_name character varying(255), -- 功能名称
  function_description text,
  CONSTRAINT call_functions_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_functions
  OWNER TO postgres;
COMMENT ON COLUMN call_functions.function_name IS '功能名称';

-- Table: call_gateway

-- DROP TABLE call_gateway;

CREATE TABLE call_gateway
(
  id bigserial NOT NULL,
  gateway_name character varying(255), -- 网关名称
  gateway_url character varying(255),
  call_prefix character varying(50), -- 出局冠字
  max_call integer, -- 网关最大的并发线路数
  CONSTRAINT "PK_CALL_GATEWAY_ID" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_gateway
  OWNER TO postgres;
COMMENT ON COLUMN call_gateway.gateway_name IS '网关名称';
COMMENT ON COLUMN call_gateway.call_prefix IS '出局冠字';
COMMENT ON COLUMN call_gateway.max_call IS '网关最大的并发线路数';

-- Table: call_group

-- DROP TABLE call_group;

CREATE TABLE call_group
(
  id bigserial NOT NULL,
  group_name character varying(50) NOT NULL, -- 外呼组的组名
  CONSTRAINT "PK_CALL_GROUP_ID" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_group
  OWNER TO postgres;
COMMENT ON COLUMN call_group.group_name IS '外呼组的组名';

-- Table: call_group_callout

-- DROP TABLE call_group_callout;

CREATE TABLE call_group_callout
(
  id bigserial NOT NULL,
  callout_name character varying(255),
  number_group_id bigint, -- 呼叫号码组
  number_group_uploadfile character varying(255),
  run_position bigint,
  time_rule_id bigint,
  start_time timestamp without time zone,
  stop_time timestamp without time zone,
  ring_id bigint,
  after_ring_play integer, -- 彩铃后的操作，和call_after_opt对应，主要是继续彩铃，挂机，转座席
  ring_timeout integer, -- 振铃时长,当到时未接听则挂机
  group_id bigint, -- 呼叫的座席组
  call_project_id bigint,
  concurr_type_id bigint, -- 并发类型，0为按在线坐席数量的比例，1为指定值
  concurr_number numeric, -- 并发倍数，按并发类型处理并发数
  callout_state_id bigint,
  total_number integer DEFAULT 0,
  wait_number integer DEFAULT 0, -- 等待数量
  success_number integer DEFAULT 0, -- 接通数量
  failed_number integer DEFAULT 0, -- 接通失败数量
  cancel_number integer DEFAULT 0, -- 取消的数量
  has_parse_from_file boolean DEFAULT false, -- 当上传了文件后，是否从文件中解析了内容插到数据表中，解析结束后置为true
  callout_gateway_id bigint,
  max_concurr_number integer, -- 最大并发数，前一个concurr_number为并发倍数
  second_ring_id bigint, -- 由after_ring_play定为播放彩铃生效
  second_after_ring_opt integer DEFAULT 0, -- 第二次再播放后的操作，和call_after_opt对应
  after_ring_key character varying(40), -- 播放语音时按键中止播放
  after_key_opt_id integer, -- 按键后的操作，和call_after_opt对应
  outside_line_number character varying(20), -- 外呼时，如手机上显示的来电号码，需运营商许可通过
  CONSTRAINT call_group_callout_pkey PRIMARY KEY (id),
  CONSTRAINT "FK_CALLOUT_AFTER_KEY_OPT" FOREIGN KEY (after_key_opt_id)
      REFERENCES call_after_opt (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALLOUT_SECOND_RING_ID" FOREIGN KEY (second_ring_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALLOUT_SECOND_RING_PLAY_OPT" FOREIGN KEY (second_after_ring_opt)
      REFERENCES call_after_opt (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_CALLOUT_AFTER_OPT_ID" FOREIGN KEY (after_ring_play)
      REFERENCES call_after_opt (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_CALLOUT_GATEWAY_ID" FOREIGN KEY (callout_gateway_id)
      REFERENCES callout_gateways (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_GROUP_CALLOUT_GROUP_ID" FOREIGN KEY (number_group_id)
      REFERENCES call_group (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_GROUP_CALLOUT_GROUP_ID_E" FOREIGN KEY (group_id)
      REFERENCES call_extension_groups (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_GROUP_CALLOUT_RING_ID" FOREIGN KEY (ring_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_GROUP_CALLOUT_STATE_ID" FOREIGN KEY (callout_state_id)
      REFERENCES call_group_callout_state (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_GROUP_CALLOUT_TIME_ID" FOREIGN KEY (time_rule_id)
      REFERENCES call_time_plan (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_group_callout
  OWNER TO postgres;
COMMENT ON COLUMN call_group_callout.number_group_id IS '呼叫号码组';
COMMENT ON COLUMN call_group_callout.after_ring_play IS '彩铃后的操作，和call_after_opt对应，主要是继续彩铃，挂机，转座席';
COMMENT ON COLUMN call_group_callout.ring_timeout IS '振铃时长,当到时未接听则挂机';
COMMENT ON COLUMN call_group_callout.group_id IS '呼叫的座席组';
COMMENT ON COLUMN call_group_callout.concurr_type_id IS '并发类型，0为按在线坐席数量的比例，1为指定值';
COMMENT ON COLUMN call_group_callout.concurr_number IS '并发倍数，按并发类型处理并发数';
COMMENT ON COLUMN call_group_callout.wait_number IS '等待数量';
COMMENT ON COLUMN call_group_callout.success_number IS '接通数量';
COMMENT ON COLUMN call_group_callout.failed_number IS '接通失败数量';
COMMENT ON COLUMN call_group_callout.cancel_number IS '取消的数量';
COMMENT ON COLUMN call_group_callout.has_parse_from_file IS '当上传了文件后，是否从文件中解析了内容插到数据表中，解析结束后置为true';
COMMENT ON COLUMN call_group_callout.max_concurr_number IS '最大并发数，前一个concurr_number为并发倍数';
COMMENT ON COLUMN call_group_callout.second_ring_id IS '由after_ring_play定为播放彩铃生效';
COMMENT ON COLUMN call_group_callout.second_after_ring_opt IS '第二次再播放后的操作，和call_after_opt对应';
COMMENT ON COLUMN call_group_callout.after_ring_key IS '播放语音时按键中止播放';
COMMENT ON COLUMN call_group_callout.after_key_opt_id IS '按键后的操作，和call_after_opt对应';
COMMENT ON COLUMN call_group_callout.outside_line_number IS '外呼时，如手机上显示的来电号码，需运营商许可通过';


-- Index: "IDX_CALL_GROUP_CALLOUT_MAIN"

-- DROP INDEX "IDX_CALL_GROUP_CALLOUT_MAIN";

CREATE INDEX "IDX_CALL_GROUP_CALLOUT_MAIN"
  ON call_group_callout
  USING btree
  (id, callout_name COLLATE pg_catalog."default", number_group_id, start_time, stop_time, ring_id, group_id, concurr_type_id, concurr_number);

-- Table: call_group_callout_state

-- DROP TABLE call_group_callout_state;

CREATE TABLE call_group_callout_state
(
  id integer NOT NULL,
  state_name character varying(255) NOT NULL,
  CONSTRAINT call_group_callout_state_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_group_callout_state
  OWNER TO postgres;
-- Table: call_hangup_cause

-- DROP TABLE call_hangup_cause;

CREATE TABLE call_hangup_cause
(
  id bigint NOT NULL,
  hangup_cause character varying(200),
  hangup_cause_desc text,
  CONSTRAINT "PK_CALL_HANGUP_CAUSE" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_hangup_cause
  OWNER TO postgres;
-- Table: call_in_out_event

-- DROP TABLE call_in_out_event;

CREATE TABLE call_in_out_event
(
  id bigserial NOT NULL,
  aleg_number character(50), -- a leg number
  bleg_number character(50), -- bleg number
  router_number character varying(50), -- 路由号码，如外线89999999经过8888888进来后，转给了内线8008,88888888就是路由号码
  event_id integer DEFAULT 1, -- 事件id
  event_time timestamp without time zone, -- 事件触发时间
  is_read boolean, -- 是否已读取到客户端，当读取结束并有返回消息时，删除掉它
  extension_id bigint,
  CONSTRAINT "PK_CALL_IN_OUT_EVENT" PRIMARY KEY (id),
  CONSTRAINT "FK_CALL_IN_OUT_EVENT_EXT_ID" FOREIGN KEY (extension_id)
      REFERENCES call_extension (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IN_OUT_EVENT_TYPE" FOREIGN KEY (event_id)
      REFERENCES call_in_out_event_type (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_in_out_event
  OWNER TO postgres;
COMMENT ON COLUMN call_in_out_event.aleg_number IS 'a leg number';
COMMENT ON COLUMN call_in_out_event.bleg_number IS 'bleg number';
COMMENT ON COLUMN call_in_out_event.router_number IS '路由号码，如外线89999999经过8888888进来后，转给了内线8008,88888888就是路由号码';
COMMENT ON COLUMN call_in_out_event.event_id IS '事件id';
COMMENT ON COLUMN call_in_out_event.event_time IS '事件触发时间';
COMMENT ON COLUMN call_in_out_event.is_read IS '是否已读取到客户端，当读取结束并有返回消息时，删除掉它';

-- Table: call_in_out_event_type

-- DROP TABLE call_in_out_event_type;

CREATE TABLE call_in_out_event_type
(
  id integer NOT NULL,
  event_name character varying(50), -- 事件名称
  event_desc text,
  CONSTRAINT "PK_CALL_IN_OUT_EVENT_TYPE" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_in_out_event_type
  OWNER TO postgres;
COMMENT ON COLUMN call_in_out_event_type.event_name IS '事件名称';

-- Table: call_ivr_menu_options

-- DROP TABLE call_ivr_menu_options;

CREATE TABLE call_ivr_menu_options
(
  id bigserial NOT NULL,
  ivr_menu_id bigint,
  ivr_menu_option_digits character varying(50),
  ivr_menu_option_param character varying(1000),
  ivr_menu_option_order integer,
  ivr_menu_option_description text,
  ivr_menu_option_action_id integer,
  ring_id bigint DEFAULT 0,
  CONSTRAINT call_ivr_menu_options_pkey PRIMARY KEY (id),
  CONSTRAINT "FK_IVR_MENU_OPTIONS_MENU_ID" FOREIGN KEY (ivr_menu_id)
      REFERENCES call_ivr_menus (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_IVR_MENU_OPTIONS_OPERATION_ID" FOREIGN KEY (ivr_menu_option_action_id)
      REFERENCES call_operation (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_IVR_MENU_OPTIONS_RING_ID" FOREIGN KEY (ring_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_ivr_menu_options
  OWNER TO postgres;

-- Index: "IDX_CALL_IVR_MENU_OPTIONS_MAIN"

-- DROP INDEX "IDX_CALL_IVR_MENU_OPTIONS_MAIN";

CREATE INDEX "IDX_CALL_IVR_MENU_OPTIONS_MAIN"
  ON call_ivr_menu_options
  USING btree
  (id, ivr_menu_id);

-- Table: call_ivr_menus

-- DROP TABLE call_ivr_menus;

CREATE TABLE call_ivr_menus
(
  id bigserial NOT NULL,
  ivr_menu_name character varying(200),
  ivr_menu_extension text,
  ivr_menu_confirm_macro character varying(200),
  ivr_menu_confirm_key character varying(200),
  ivr_menu_confirm_attempts integer, -- 尝试次数
  ivr_menu_timeout integer, -- 超时秒数
  ivr_menu_exit_data text,
  ivr_menu_inter_digit_timeout integer, -- 中间不按键时的超时时间
  ivr_menu_max_failures integer, -- 输错ivr的最大次数
  ivr_menu_max_timeouts integer, -- ivr最大超时次数
  ivr_menu_digit_len integer, -- 数字按键最大长度
  ivr_menu_direct_dial character varying(200),
  ivr_menu_cid_prefix character varying(200),
  ivr_menu_description text, -- 说明
  ivr_menu_call_crycle_order integer, -- 针对属于循环呼叫的，实时记录当前呼叫的子节点的order
  ivr_menu_enabled boolean,
  ivr_menu_call_order_id bigint,
  ivr_menu_greet_long_id bigint,
  ivr_menu_greet_short_id bigint,
  ivr_menu_invalid_sound_id bigint,
  ivr_menu_exit_sound_id bigint,
  ivr_menu_ringback_id bigint,
  ivr_menu_exit_app_id integer,
  CONSTRAINT "PK_CALL_IVR_MENU_KEY" PRIMARY KEY (id),
  CONSTRAINT "FK_CALL_IVR_MENUS_EXIT_RING_ID" FOREIGN KEY (ivr_menu_exit_sound_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IVR_MENUS_INVALID_RING_ID" FOREIGN KEY (ivr_menu_invalid_sound_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IVR_MENUS_LONG_RING_ID" FOREIGN KEY (ivr_menu_greet_long_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IVR_MENUS_OPERATION_ID" FOREIGN KEY (ivr_menu_exit_app_id)
      REFERENCES call_operation (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IVR_MENUS_ORDER_ID" FOREIGN KEY (ivr_menu_call_order_id)
      REFERENCES call_order (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IVR_MENUS_RINGBACK_RING_ID" FOREIGN KEY (ivr_menu_ringback_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_IVR_MENUS_SHORT_RING_ID" FOREIGN KEY (ivr_menu_greet_short_id)
      REFERENCES call_rings (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_ivr_menus
  OWNER TO postgres;
COMMENT ON COLUMN call_ivr_menus.ivr_menu_confirm_attempts IS '尝试次数';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_timeout IS '超时秒数';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_inter_digit_timeout IS '中间不按键时的超时时间';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_max_failures IS '输错ivr的最大次数';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_max_timeouts IS 'ivr最大超时次数';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_digit_len IS '数字按键最大长度';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_description IS '说明';
COMMENT ON COLUMN call_ivr_menus.ivr_menu_call_crycle_order IS '针对属于循环呼叫的，实时记录当前呼叫的子节点的order';

-- Table: call_operation

-- DROP TABLE call_operation;

CREATE TABLE call_operation
(
  id integer NOT NULL,
  name character varying(255),
  description character varying(255),
  CONSTRAINT call_operation_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_operation
  OWNER TO postgres;
-- Table: call_order

-- DROP TABLE call_order;

CREATE TABLE call_order
(
  id bigint NOT NULL,
  order_name character varying(255),
  order_description text, -- 呼叫类型说明
  CONSTRAINT call_order_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_order
  OWNER TO postgres;
COMMENT ON TABLE call_order
  IS '呼叫类型表';
COMMENT ON COLUMN call_order.order_description IS '呼叫类型说明';

-- Table: call_out_numbers

-- DROP TABLE call_out_numbers;

CREATE TABLE call_out_numbers
(
  id bigserial NOT NULL,
  group_id bigint,
  "number" character varying(50),
  is_called integer DEFAULT 0, -- 是否呼叫过了
  call_state integer DEFAULT 0, -- 呼叫状态
  start_time timestamp without time zone,
  answer_time timestamp without time zone,
  hangup_time timestamp without time zone,
  hangup_reason_id bigint,
  answer_extension_id bigint,
  record_file character varying(255), -- 录音文件
  wait_sec integer, -- 等待时长
  cdr_id bigint, -- 记录这个呼叫的cdr的id
  CONSTRAINT call_out_numbers_pkey PRIMARY KEY (id),
  CONSTRAINT "FK_CALL_OUT_NUMBERS_EXTENSION_ID" FOREIGN KEY (answer_extension_id)
      REFERENCES call_extension (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_OUT_NUMBERS_GROUP_ID" FOREIGN KEY (group_id)
      REFERENCES call_group (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_CALL_OUT_NUMBERS_HANGUP_RESON_ID" FOREIGN KEY (hangup_reason_id)
      REFERENCES call_hangup_cause (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_out_numbers
  OWNER TO postgres;
COMMENT ON COLUMN call_out_numbers.is_called IS '是否呼叫过了';
COMMENT ON COLUMN call_out_numbers.call_state IS '呼叫状态';
COMMENT ON COLUMN call_out_numbers.record_file IS '录音文件';
COMMENT ON COLUMN call_out_numbers.wait_sec IS '等待时长';
COMMENT ON COLUMN call_out_numbers.cdr_id IS '记录这个呼叫的cdr的id';


-- Index: "IDX_CALL_OUT_NUMBERS_MAIN"

-- DROP INDEX "IDX_CALL_OUT_NUMBERS_MAIN";

CREATE INDEX "IDX_CALL_OUT_NUMBERS_MAIN"
  ON call_out_numbers
  USING btree
  (id, group_id, number COLLATE pg_catalog."default", is_called, call_state, start_time, answer_time, hangup_time, hangup_reason_id);

-- Table: call_outside_config

-- DROP TABLE call_outside_config;

CREATE TABLE call_outside_config
(
  id bigserial NOT NULL,
  outside_line_name character varying(50), -- 外线名称
  outside_line_number character varying(50), -- 外线号码
  inside_line_number character varying(50) DEFAULT NULL::character varying, -- 内线号码
  call_order_id bigint DEFAULT 0, -- 呼叫顺序，外线可以直转内线号码，而不用配置多余的ivr
  call_crycle_order bigint DEFAULT 0, -- 循环呼叫的当前呼叫到的值
  is_record boolean DEFAULT false,
  is_voice_mail boolean DEFAULT false,
  CONSTRAINT "PK_OUTSIDE_LINE_ID" PRIMARY KEY (id),
  CONSTRAINT "FK_OUTSIDE_CONFIG_ORDER_ID" FOREIGN KEY (call_order_id)
      REFERENCES call_order (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_outside_config
  OWNER TO postgres;
COMMENT ON COLUMN call_outside_config.outside_line_name IS '外线名称';
COMMENT ON COLUMN call_outside_config.outside_line_number IS '外线号码';
COMMENT ON COLUMN call_outside_config.inside_line_number IS '内线号码';
COMMENT ON COLUMN call_outside_config.call_order_id IS '呼叫顺序，外线可以直转内线号码，而不用配置多余的ivr';
COMMENT ON COLUMN call_outside_config.call_crycle_order IS '循环呼叫的当前呼叫到的值';


-- Index: "IDX_CALL_OUTSIDE_CONFIG_MAIN"

-- DROP INDEX "IDX_CALL_OUTSIDE_CONFIG_MAIN";

CREATE INDEX "IDX_CALL_OUTSIDE_CONFIG_MAIN"
  ON call_outside_config
  USING btree
  (id, outside_line_name COLLATE pg_catalog."default", outside_line_number COLLATE pg_catalog."default", inside_line_number COLLATE pg_catalog."default");

-- Table: call_rings

-- DROP TABLE call_rings;

CREATE TABLE call_rings
(
  id bigserial NOT NULL,
  ring_name character varying(200),
  ring_path character varying(255),
  ring_description text,
  ring_category bigint, -- 彩铃的类型，如ivr,voicemail,等等
  CONSTRAINT "PK_CALL_RING_ID" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_rings
  OWNER TO postgres;
COMMENT ON COLUMN call_rings.ring_category IS '彩铃的类型，如ivr,voicemail,等等
';


-- Index: "IDX_CALL_RINGS_MAIN"

-- DROP INDEX "IDX_CALL_RINGS_MAIN";

CREATE INDEX "IDX_CALL_RINGS_MAIN"
  ON call_rings
  USING btree
  (id, ring_name COLLATE pg_catalog."default", ring_path COLLATE pg_catalog."default");

-- Table: call_time_plan

-- DROP TABLE call_time_plan;

CREATE TABLE call_time_plan
(
  id bigint NOT NULL,
  name character varying(255) NOT NULL,
  plan_timing boolean DEFAULT false, -- 定时执行
  plan_date date,
  per_hour boolean DEFAULT false,
  per_day boolean DEFAULT false,
  per_month boolean DEFAULT false,
  is_monday boolean DEFAULT false,
  is_tuesday boolean DEFAULT false,
  is_wednesday boolean DEFAULT false,
  is_thursday boolean DEFAULT false,
  is_friday boolean DEFAULT false,
  is_saturday boolean DEFAULT false,
  is_sunday boolean DEFAULT false,
  CONSTRAINT call_time_plan_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_time_plan
  OWNER TO postgres;
COMMENT ON COLUMN call_time_plan.plan_timing IS '定时执行';


-- Index: "IDX_CALL_TIME_PLAN_MAIN"

-- DROP INDEX "IDX_CALL_TIME_PLAN_MAIN";

CREATE INDEX "IDX_CALL_TIME_PLAN_MAIN"
  ON call_time_plan
  USING btree
  (id, name COLLATE pg_catalog."default", plan_timing, plan_date, per_hour, per_day, per_month, is_monday, is_tuesday, is_wednesday, is_thursday, is_friday, is_saturday);

-- Table: call_voicemail

-- DROP TABLE call_voicemail;

CREATE TABLE call_voicemail
(
  id bigserial NOT NULL,
  extension_id bigint NOT NULL,
  voicemail_password character varying(50),
  greeting_id bigint,
  voicemail_mail_to character varying(50),
  voicemail_attach_file character varying(255),
  voicemail_local_after_email character varying(255),
  voicemail_enabled character varying(50),
  voicemail_desc text,
  CONSTRAINT "PK_CALL_VOICEMAIL_ID" PRIMARY KEY (id),
  CONSTRAINT "FK_CALL_VOICEMAIL_EXTENSION_ID" FOREIGN KEY (extension_id)
      REFERENCES call_extension (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE call_voicemail
  OWNER TO postgres;

-- Index: "IDX_CALL_VOICEMAIL_MAIN"

-- DROP INDEX "IDX_CALL_VOICEMAIL_MAIN";

CREATE INDEX "IDX_CALL_VOICEMAIL_MAIN"
  ON call_voicemail
  USING btree
  (id, extension_id, voicemail_attach_file COLLATE pg_catalog."default", voicemail_local_after_email COLLATE pg_catalog."default", voicemail_enabled COLLATE pg_catalog."default");

-- Table: callout_gateways

-- DROP TABLE callout_gateways;

CREATE TABLE callout_gateways
(
  id integer NOT NULL,
  name character varying(255) NOT NULL,
  gateway_id bigint,
  CONSTRAINT callout_gateways_pkey PRIMARY KEY (id),
  CONSTRAINT "FK_CALLOUT_GATEWAY_GATEWAY_ID" FOREIGN KEY (gateway_id)
      REFERENCES call_gateway (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE callout_gateways
  OWNER TO postgres;
-- Table: in_out_mapping

-- DROP TABLE in_out_mapping;

CREATE TABLE in_out_mapping
(
  id bigserial NOT NULL,
  outside_line_id bigint DEFAULT 0,
  inside_line_id bigint DEFAULT 0,
  order_number integer DEFAULT 0, -- 排序的序列从1开始
  CONSTRAINT in_out_mapping_pkey PRIMARY KEY (id),
  CONSTRAINT "FK_IN_OUT_MAPPING_IN_LINE_ID" FOREIGN KEY (inside_line_id)
      REFERENCES call_extension (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT "FK_IN_OUT_MAPPING_OUT_LINE_ID" FOREIGN KEY (outside_line_id)
      REFERENCES call_outside_config (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE in_out_mapping
  OWNER TO postgres;
COMMENT ON COLUMN in_out_mapping.order_number IS '排序的序列从1开始';


-- Index: "IDX_IN_OUT_MAPPING_MAIN"

-- DROP INDEX "IDX_IN_OUT_MAPPING_MAIN";

CREATE INDEX "IDX_IN_OUT_MAPPING_MAIN"
  ON in_out_mapping
  USING btree
  (id, outside_line_id, inside_line_id, order_number);

-- Table: number_paragraph

-- DROP TABLE number_paragraph;

CREATE TABLE number_paragraph
(
  number_paragraph character varying(50) NOT NULL,
  CONSTRAINT number_paragraph_pkey PRIMARY KEY (number_paragraph)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE number_paragraph
  OWNER TO postgres;

-- Index: "IDX_NUMBER_PARAGRAPH_MAIN"

-- DROP INDEX "IDX_NUMBER_PARAGRAPH_MAIN";

CREATE INDEX "IDX_NUMBER_PARAGRAPH_MAIN"
  ON number_paragraph
  USING btree
  (number_paragraph COLLATE pg_catalog."default");


