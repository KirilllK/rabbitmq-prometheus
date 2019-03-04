%% The contents of this file are subject to the Mozilla Public License
%% Version 1.1 (the "License"); you may not use this file except in
%% compliance with the License. You may obtain a copy of the License at
%% http://www.mozilla.org/MPL/
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%% License for the specific language governing rights and limitations
%% under the License.
%%
%% The Original Code is RabbitMQ.
%%
%% The Initial Developer of the Original Code is GoPivotal, Inc.
%% Copyright (c) 2007-2019 Pivotal Software, Inc.  All rights reserved.
%%

-module(rabbit_prometheus_dispatcher).

-export([build_dispatcher/0]).

-define(DEFAULT_PATH, "/metrics").

build_dispatcher() ->
    {ok, _} = application:ensure_all_started(prometheus),
    maybe_register_collectors(),
    prometheus_http_impl:setup(),
    cowboy_router:compile([{'_', dispatcher()}]).

dispatcher() ->
    [{path() ++ "/[:registry]", rabbit_prometheus_handler, []}].

maybe_register_collectors() ->
    prometheus_registry:register_collectors([prometheus_rabbitmq_core_metrics_collector]).

path() ->
    Config = application:get_env(rabbitmq_prometheus, path, []),
    proplists:get_value(path, Config, ?DEFAULT_PATH).
