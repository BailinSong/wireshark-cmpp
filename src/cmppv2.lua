-- CMPPv2.lua
-- author: zhanghaifeng

local p_cmppv2 = Proto("CMPPv2", "China Mobile Peer to Peer Protocol v2.0")
local f_length = ProtoField.uint32("CMPPv2.length","MsgLength(消息长度)",base.DEC)
local f_command_id = ProtoField.uint32("CMPPv2.commandId","CommandId(消息类型)",base.HEX,{
    [1] = "Connect",
    [2] = "Terminate",
    [4] = "Submit",
    [5] = "Deliver",
    [6] = "Query",
    [8] = "ActiveTest",
    [0x80000001] = "ConnectResp",
    [0x80000002] = "TerminateResp",
    [0x80000004] = "SubmitResp",
    [0x80000005] = "DeliverResp",
    [0x80000006] = "QueryResp",
    [0x80000008] = "ActiveTestResp"
})
local f_sequence_id = ProtoField.uint32("CMPPv2.sequenceId","SequenceId(序列号)",base.DEC);
local f_msg_id_timestamp = ProtoField.string("CMPPv2.msgIdTimestamp","时间戳")
local f_msg_id_sgw_id = ProtoField.uint32("CMPPv2.msgIdSgwId","网关Id");
local f_msg_id_sequence = ProtoField.uint16("CMPPv2.msgIdSequence","序号");
local f_message_id = ProtoField.bytes("CMPPv2.messageId","MsgId(消息Id)")
local f_pk_total = ProtoField.uint8("CMPPv2.pkTotal","PkTotal(相同消息Id的信息总条数)")
local f_pk_number = ProtoField.uint8("CMPPv2.pkNumber","PkNumber(相同消息Id的信息序号)")
local yes_or_no = {
    [1] = "是",
    [0] = "否"
}
local f_registered_delivery = ProtoField.uint8("CMPPv2.registeredDelivery","RegisteredDelivery(是否返回状态报告)", base.DEC, yes_or_no)
local f_is_delivery_report = ProtoField.uint8("CMPPv2.isReport","RegisteredDelivery(是否状态报告)", base.DEC, yes_or_no)
local f_message_level = ProtoField.uint8("CMPPv2.messageLevel","MsgLevel(消息级别)")
local f_service_id = ProtoField.string("CMPPv2.serviceId","ServiceId(业务类型)")
local f_fee_user_type = ProtoField.uint8("CMPPv2.feeUserType","FeeUserType(计费类型)", base.DEC, {
    [0] = "对目的终端MSISDN计费",
    [1] = "对源终端MSISDN计费",
    [2] = "对SP计费",
    [3] = "本字段无效"
})
local f_fee_terminal_id = ProtoField.string("CMPPv2.feeTerminalId","FeeTerminalId(计费用户号码)")
local f_message_src = ProtoField.string("CMPPv2.messageSrc","MessageSrc(信息内容来源)")
local f_src_id = ProtoField.string("CMPPv2.srcId","SrcId(源号码)")
local f_SrcTerminalId = ProtoField.string("CMPPv2.srcTerminalId","SrcTerminalId(源终端号码)")
local f_reserved = ProtoField.bytes("CMPPv2.reserved","Reserve(保留域)")

local f_data = ProtoField.bytes("CMPPv2.data","Data(字节数据)")
local f_result = ProtoField.uint8("CMPPv2.result","Result(结果)",base.DEC,{
    [0] = "成功",
    [1] = "消息结构错",
    [2] = "命令字错",
    [3] = "消息序号重复",
    [4] = "消息长度错",
    [5] = "资费代码错",
    [6] = "超过最大信息长",
    [7] = "业务代码错",
    [8] = "流量控制错",
    [9] = "其他错误"
})
local f_dest_user_count = ProtoField.uint8("CMPPv2.destUserCount","DestUserCount(接收用户数)",base.DEC)
local f_dest_terminal_id = ProtoField.string("CMPPv2.destTerminalId","DestTerminalId(接收用户号码)")
local f_fee_type = ProtoField.uint16("CMPPv2.feeType","FeeType(计费类型)", base.HEX, {
    [0x03031] = "免费",
    [0x03032] = "按条计费",
    [0x03033] = "包月收费",
    [0x03034] = "封顶收费",
    [0x03035] = "SP收取"
})
local f_fee_value = ProtoField.string("CMPPv2.feeValue","FeeValue(资费)")
local f_valid_time = ProtoField.string("CMPPv2.validTime","ValidTime(有效期)")
local f_at_time = ProtoField.string("CMPPv2.atTime","AtTime(定时发送时间)")
local f_tp_pid = ProtoField.uint8("CMPPv2.tpPid","TpPid(TP协议标识符)")
local f_tp_udhi = ProtoField.uint8("CMPPv2.tpUdhi","TpUdhi(TP用户数据首部指示符)", base.DEC, {
    [0] = "用户数据只含短信内容",
    [1] = "用户数据含首部及短信内容"
})
local f_msg_fmt = ProtoField.uint8("CMPPv2.messageFormat","MsgFmt(内容编码)", base.DEC, {
    [0] = "ASCII",
    [3] = "短信写卡",
    [4] = "二进制",
    [8] = "UCS2",
    [15] = "GB18030"
})
local f_message_length = ProtoField.uint8("CMPPv2.messageLength","MessageLength(消息内容字节数)")
local f_msg_content = ProtoField.bytes("CMPPv2.msgContent","MsgContent(消息内容)")
local f_msg_content_decoded = ProtoField.string("CMPPv2.messageContentDecoded","MessageContentDecoded")
local f_dest_id = ProtoField.string("CMPPv2.destId","DestId(接收号码)")
-- 状态报告内容中的各字段
local f_content_msg_id = ProtoField.bytes("CMPPv2.contentMsgId","MsgId(消息Id)")
local f_content_stat = ProtoField.string("CMPPv2.contentStat","Stat(应答结果)")
local f_content_submit_time = ProtoField.string("CMPPv2.contentSubmitTime","SubmitTime(提交时间)")
local f_content_done_time = ProtoField.string("CMPPv2.contentDoneTime","DoneTime(完成时间)")
local f_content_dest_terminal_id = ProtoField.string("CMPPv2.contentDestTerminalId","DestTerminalId(目的终端号码)")
local f_content_sequence = ProtoField.uint32("CMPPv2.contentSequence","Sequence(序列号)")

local f_source_addr = ProtoField.string("CMPPv2.sourceAddr","SourceAddr(源地址)")
local f_authenticator_source = ProtoField.string("CMPPv2.authenticatorSource","AuthenticatorSource(源地址认证码)")
local f_version = ProtoField.uint8("CMPPv2.version","Version(版本号)")
local f_timestamp = ProtoField.uint32("CMPPv2.timestamp","Timestamp(时间戳)")
local f_status = ProtoField.uint8("CMPPv2.status","Status(状态)", base.DEC, {[0] = "成功"})
local f_authenticator_ismg = ProtoField.string("CMPPv2.authenticatorIsmg","AuthenticatorIsmg(短信网关认证码)")
local f_msg_content_header = ProtoField.bytes("CMPPv2.messageContentHeader", "Header(首部)")

p_cmppv2.fields = {
    f_length, f_command_id, f_sequence_id, f_data, f_result, f_dest_user_count, f_dest_terminal_id,
    f_fee_type, f_fee_value, f_valid_time, f_at_time, f_tp_pid, f_tp_udhi, f_msg_fmt, f_message_length, f_msg_content,
    f_message_id, f_pk_total, f_pk_number, f_registered_delivery, f_message_level, f_service_id, f_fee_user_type,
    f_fee_terminal_id, f_message_src, f_src_id, f_reserved, f_msg_id_timestamp, f_msg_id_sgw_id, f_msg_id_sequence,
    f_SrcTerminalId, f_dest_id, f_content_msg_id, f_content_stat, f_content_submit_time, f_content_done_time,
    f_content_dest_terminal_id, f_content_sequence, f_is_delivery_report, f_msg_content_header
}

-- 处理MessageId：除MessageId本身外，还解析其中包含的时间戳、网关Id和序列号
local function process_message_id(field, buffer, t)
    local node = t:add(field, buffer)
    node:add(f_msg_id_timestamp, tostring(buffer:bitfield(0, 4)) .. "/" .. tostring(buffer:bitfield(4, 5)) .. " " .. tostring(buffer:bitfield(9, 5)) .. ":" .. tostring(buffer:bitfield(14, 6)) .. ":" .. tostring(buffer:bitfield(20, 6)))
    node:add(f_msg_id_sgw_id, buffer:bitfield(26, 22))
    node:add(f_msg_id_sequence, buffer:bitfield(48, 16))
end

-- 解码短信内容：根据编码方式解码短信内容
local function decode_content(buf, length, format)
    if (format == 8) then
        return buf(0, length):ustring();
    elseif (format == 0) then
        return buf(0, length):string();
    else
        return "API无法解码该编码的内容"
    end
end

-- 处理短信内容：根据长短信标识及编码方式处理短信内容
local function process_content(buf, pos, length, udhi, encoding, t)
    local node = t:add(f_msg_content, buf(pos, length))
    local head_length
    if (udhi == 1) then
        head_length = buf(pos, 1):uint() + 1
        node:add(f_msg_content_header, buf(pos, head_length))
    else
        head_length = 0
    end
    node:add(f_msg_content_decoded, "Decoded(解码后内容): " .. decode_content(buf(pos + head_length), length - head_length, encoding))
end

-- 解析connect
local function parse_connect(buf, t)
    t:add(f_source_addr, buf(12, 6), t)
    t:add(f_authenticator_source, buf(18, 16), t)
    t:add(f_version, buf(34, 1), t)
    t:add(f_timestamp, buf(35, 4), t)
end

-- 解析connect_resp
local function parse_connect_resp(buf, t)
    t:add(f_status, buf(12, 1), t)
    t:add(f_authenticator_ismg, buf(13, 16), t)
    t:add(f_version, buf(29, 1), t)
end

-- 解析submit
local function parse_submit(buf, t)
    process_message_id(f_message_id, buf(12, 8), t)
    t:add(f_pk_total, buf(20, 1))
    t:add(f_pk_number, buf(21, 1))
    t:add(f_registered_delivery, buf(22, 1))
    t:add(f_message_level, buf(23, 1))
    t:add(f_service_id, buf(24, 10))
    t:add(f_fee_user_type, buf(34, 1))
    t:add(f_fee_terminal_id, buf(35, 21))
    t:add(f_tp_pid, buf(56, 1))
    t:add(f_tp_udhi, buf(57, 1))
    t:add(f_msg_fmt, buf(58, 1))
    t:add(f_message_src, buf(59, 6))
    t:add(f_fee_type, buf(65, 2))
    t:add(f_fee_value, buf(67, 6))
    t:add(f_valid_time, buf(73, 17))
    t:add(f_at_time, buf(90, 17))
    t:add(f_src_id, buf(107, 21))
    t:add(f_dest_user_count, buf(128, 1))

    local user_num = buf(128, 1):uint();
    local pos = 129
    for i = 1, user_num do
        t:add(f_dest_terminal_id, buf(pos, 21))
        pos = pos + 21
    end
    t:add(f_message_length, buf(pos, 1))
    local length = buf(pos, 1):uint()
    process_content(buf, pos + 1, length, buf(57, 1):uint(), buf(58, 1):uint(), t)
    t:add(f_reserved, buf(pos + 1 + length, 8))
end

-- 解析deliver
local function parse_deliver(buf, t)
    -- 处理MessageId
    process_message_id(f_message_id, buf(12, 8), t)
    t:add(f_dest_id, buf(20, 21))
    t:add(f_service_id, buf(41, 10))
    t:add(f_tp_pid, buf(51, 1))
    t:add(f_tp_udhi, buf(52, 1))
    t:add(f_msg_fmt, buf(53, 1))
    t:add(f_SrcTerminalId, buf(54, 21))
    t:add(f_is_delivery_report, buf(75, 1))
    t:add(f_message_length, buf(76, 1))
    local length = buf(76, 1):uint()

    if (length > 0) then
        if (buf(75, 1):uint() == 1) then
            local content = t:add(f_msg_content, buf(77, length))
            process_message_id(f_content_msg_id, buf(77, 8), content)
            content:add(f_content_stat, buf(85, 7))
            content:add(f_content_submit_time, buf(92, 10))
            content:add(f_content_done_time, buf(102, 10))
            content:add(f_content_dest_terminal_id, buf(112, 21))
            content:add(f_content_sequence, buf(133, 4))
        else
            process_content(buf, 77, length, buf(52, 1):uint(), buf(53, 1):uint(), t);
        end
    end
    t:add(f_reserved, buf(77 + length, 8))
end

-- 解析响应
local function parse_response(buf, t)
    process_message_id(f_message_id, buf(12, 8), t)
    t:add(f_result, buf(20, 1))
end

local function cmppv2_dissector(buf,pkt,root)
    local buf_len = buf:len();
    if buf_len < 8 then
        return false
    end

    pkt.cols.protocol = "CMPPv2"
    local t = root:add(p_cmppv2, buf(0, buf_len))
    t:add(f_length, buf(0,4))
    t:add(f_command_id, buf(4,4))
    t:add(f_sequence_id, buf(8,4))

    local v_command = buf(4,4):uint()
    if v_command == 1 then
        parse_connect(buf, t)
    elseif v_command == 4 then
        parse_submit(buf, t)
    elseif v_command == 5 then
        parse_deliver(buf, t)
    elseif v_command == 0x80000004 or v_command == 0x80000005 then
        parse_response(buf, t)
    elseif v_command == 0x80000001 then
        parse_connect_resp(buf, t)
    else
        if (buf_len > 12) then
            t:add(f_data, buf(12, buf_len - 12))
        end
    end
    return true
end

function p_cmppv2.dissector(buf,pkt,root)
    -- 解析 CMPPv2
    if not cmppv2_dissector(buf,pkt,root) then
        -- 使用默认输出
        Dissector.get("data"):call(buf, pkt, root)
    end
end

DissectorTable.get("tcp.port"):add(7890, p_cmppv2)