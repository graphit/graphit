-module(graphit_test).

-define(PRINT(Var), io:format("DEBUG: ~p:~p - ~p~n~n ~p~n~n", [?MODULE, ?LINE, ??Var, Var])).

-include_lib("eunit/include/eunit.hrl").

test_with_graphit(Functions) ->
    {setup,
     fun start/0,
     fun stop/1,
     fun (_) -> [fun() -> F() end || F <- Functions]
     end}.

start() ->
    ok = application:load(riak_core),
    ok = riak_core_util:start_app_deps(riak_core),
    ok = application:start(riak_core),
    ok = application:load(graphit),
    ok = application:start(graphit),
    ok.

stop(_) ->
    application:stop(graphit).

%%%%%%%%%%%%%%%%%%

all_test_() ->
    test_with_graphit([
                          fun () ->
                              ?assertEqual(12345, graphit:ping())
                          end,
                          fun () ->
                              ?assertEqual(1, graphit:get("a"))
                          end,
                          fun () ->
                              ?assertEqual(undefined, graphit:get("c"))
                          end,
                          fun () ->
                               ?assertEqual(undefined, graphit:get("d")),
                               ?assertEqual(ok, graphit:put("d", 4)),
                               ?assertEqual(4, graphit:get("d"))
                          end
                      ]).
