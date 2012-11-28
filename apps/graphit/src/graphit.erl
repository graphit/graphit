-module(graphit).

-include("graphit.hrl").
-include_lib("riak_core/include/riak_core_vnode.hrl").

-export([ping/0, get/1, put/2]).

%% Public API

%% @doc Pings a random vnode to make sure communication is functional
ping() ->
    command([ping]).

get(Key) ->
    command([get, Key]).

put(Key, Value) ->
    command([put, Key, Value]).

command(C = [Cmd | _T]) ->
    CmdBin = list_to_binary(atom_to_list(Cmd)),
    DocIdx = riak_core_util:chash_key({CmdBin, term_to_binary(now())}),
    PrefList = riak_core_apl:get_primary_apl(DocIdx, 1, graphit),
    [{IndexNode, _Type}] = PrefList,
    riak_core_vnode_master:sync_spawn_command(IndexNode, C, graphit_vnode_master).
