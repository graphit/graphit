-module(graphit_vnode_test).

-include_lib("eunit/include/eunit.hrl").

%% vnode callback tests.

is_empty_test() ->
    ?assertEqual({true, fake_state}, graphit_vnode:is_empty(fake_state)).