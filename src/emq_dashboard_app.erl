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

-module(emq_dashboard_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-define(APP, emq_dashboard).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emq_dashboard_sup:start_link(),
    {ok, Listener} = application:get_env(?APP, listener),
    ok = emqttd_access_control:register_mod(auth, emq_auth_dashboard, [Listener], 9999),
    start_listener(Listener),
    emq_dashboard_cli:load(),
    {ok, Sup}.

stop(_State) ->
    emq_dashboard_cli:unload(),
    emqttd_access_control:unregister_mod(auth, emq_auth_dashboard),
    {ok, {_Proto, Port, _Opts}} = application:get_env(?APP, listener),
    mochiweb:stop_http(Port).

%% start http listener
start_listener({Name, Port, Options}) ->
    mochiweb:start_http(Name, Port, Options, emq_dashboard:http_handler()).
