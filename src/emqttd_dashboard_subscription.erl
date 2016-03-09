%%--------------------------------------------------------------------
%% Copyright (c) 2015-2016 Feng Lee <feng@emqtt.io>.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%--------------------------------------------------------------------

%% @doc Action for session api.
-module(emqttd_dashboard_subscription).

-include("emqttd_dashboard.hrl").
-include("../../../include/emqttd.hrl").

-include_lib("stdlib/include/qlc.hrl").

-export([execute/0]).

execute() ->
    case catch mnesia:dirty_all_keys(subscription) of
        {'EXIT', _Error} ->
            [];
        Keys ->
            RowFun = fun(Key) ->
                       Records = ets:lookup(subscription, Key),
                       [{clientId, Key}, {subscriptions, format(subscriptions, Records)}]
                     end,
            [RowFun(Key) || Key <- Keys]
    end.

format(subscriptions, Subscriptions) ->
    list_to_binary(
        string:join([io_lib:format("~s:~w", [Topic, Qos]) ||
                #mqtt_subscription{topic = Topic, qos = Qos} <- Subscriptions], ",")).

