-module(graphit).

-include("graphit.hrl").
-include_lib("riak_core/include/riak_core_vnode.hrl").

-export([ping/0, get/1, put/2]).

%% Public API

%% @doc Pings a random vnode to make sure communication is functional
ping() ->
    command(ping, [ping]).

get(Key) ->
    command(kv, [get, Key]).

put(Key, Value) ->
    command(kv, [put, Key, Value]).

command(Bucket, Command) ->
    DocIdx = chash_key(Bucket, Command),
    PrefList = riak_core_apl:get_primary_apl(DocIdx, 1, graphit),
    [{IndexNode, _Type}] = PrefList,
    riak_core_vnode_master:sync_spawn_command(IndexNode, Command, graphit_vnode_master).

chash_key(Bucket, [get, Key]) ->
    riak_core_util:chash_key({Bucket, term_to_binary(Key)});
chash_key(Bucket, [put, Key, _Value]) ->
    riak_core_util:chash_key({Bucket, term_to_binary(Key)});
chash_key(Bucket, [_Command]) ->
    riak_core_util:chash_key({Bucket, term_to_binary(now())}).

