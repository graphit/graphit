-module(graphit_vnode).
-behaviour(riak_core_vnode).
-include_lib("riak_core/include/riak_core_vnode.hrl").
-include("graphit.hrl").

-export([start_vnode/1,
         init/1,
         terminate/2,
         handle_command/3,
         is_empty/1,
         delete/1,
         handle_handoff_command/3,
         handoff_starting/2,
         handoff_cancelled/1,
         handoff_finished/2,
         handle_handoff_data/2,
         encode_handoff_item/2,
         handle_coverage/4,
         handle_exit/3]).

%% API
start_vnode(I) ->
    riak_core_vnode_master:get_vnode_pid(I, ?MODULE).

%% vnode callbacks
init([Partition]) ->
  {ok, #state{ partition=Partition, data=[{"a", 1}, {"b", 2}] }}.

handle_command([ping], _Sender, State) ->
    ?PRINT({ping, "Ping"}),
    {reply, 12345, State};

handle_command([get, Key], _Sender, State) ->
    ?PRINT("get"),
    ?PRINT(State#state.data),
    Value = proplists:get_value(Key, State#state.data),
    {reply, Value, State};

handle_command([put, Key, Value], _Sender, State) ->
    ?PRINT("put"),
    ?PRINT(State#state.data),
    Data = [{Key, Value} | State#state.data],
    NewState = State#state{data=Data},

    ?PRINT(NewState),
    {reply, ok, NewState};

handle_command(Message, _Sender, State) ->
    ?PRINT({unhandled_command, Message}),
    {noreply, State}.

handle_exit(_Pid, Reason, State) ->
    {stop, Reason, State}.

handle_handoff_command(_Message, _Sender, State) ->
  {noreply, State}.

handoff_starting(_TargetNode, State) ->
    {true, State}.

handoff_cancelled(State) ->
    {ok, State}.

handoff_finished(_TargetNode, State) ->
    {ok, State}.

handle_handoff_data(_Data, State) ->
    {reply, ok, State}.

encode_handoff_item(_ObjectName, _ObjectValue) ->
    <<>>.

is_empty(State) ->
    {true, State}.

delete(State) ->
    {ok, State}.

handle_coverage(_Req, _KeySpaces, _Sender, State) ->
    {stop, not_implemented, State}.

terminate(_Reason, _State) ->
    ok.
