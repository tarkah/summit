/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * summit.app
 *
 * Main application instance housing the Dashboard app
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module summit.app;

import vibe.d;
import summit.sessionstore;
import moss.db.keyvalue;
import moss.db.keyvalue.interfaces;
import moss.db.keyvalue.orm;

import summit.models;

/**
 * Main entry point from the server side, storing our
 * databases and interfaces.
 */
public final class SummitApp
{
    /**
     * Construct a new SummitApp
     */
    this() @safe
    {
        settings = new HTTPServerSettings();
        settings.disableDistHost = true;
        settings.useCompressionIfPossible = true;
        settings.bindAddresses = ["127.0.0.1"];
        settings.port = 8081;
        settings.sessionIdCookie = "summit/session_id";
        settings.sessionOptions = SessionOption.httpOnly | SessionOption.secure;
        settings.sessionStore = new DBSessionStore("lmdb://session");

        /* Get our app db open */
        appDB = Database.open("lmdb://app", DatabaseFlags.CreateIfNotExists)
            .tryMatch!((Database db) => db);

        /* Ensure all models exist */
        auto err = appDB.update((scope tx) @safe { return tx.createModel!(User); });
        enforceHTTP(err.isNull, HTTPStatus.internalServerError, err.message);

        router = new URLRouter();
    }

    /**
     * Start the app properly
     */
    void start() @safe
    {
        listener = listenHTTP(settings, router);
    }

    /**
     * Correctly stop the application
     */
    void stop() @safe
    {
        listener.stopListening();

    }

private:
    URLRouter router;
    HTTPServerSettings settings;
    HTTPListener listener;
    Database appDB;
}
