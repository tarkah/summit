/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * summit.workers
 *
 * Workers module
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module summit.workers;

import vibe.d;
public import summit.workers.messaging;
import moss.db.keyvalue;
import moss.db.keyvalue.orm;

/**
 * The WorkerSystem is responsible for managing dispatch and
 * control for various workers.
 */
public final class WorkerSystem
{
    @disable this();

    /**
     * The WorkerSystem is created with a root directory
     */
    this(string rootDir, Database appDB) @safe
    {
        this.rootDir = rootDir;
        this.appDB = appDB;
        _controlQueue = createChannel!(ControlEvent, numEvents)();
        greenQueue = createChannel!(ControlEvent, numEvents)();
        distributedQueue = createChannel!(ControlEvent, numEvents)();
    }

    /**
     * Process the queue in parallel green thread
     */
    void start() @safe
    {
        logInfo("WorkerSystem started");
        runTask({
            ControlEvent event;
            while (controlQueue.tryConsumeOne(event))
            {
                logDiagnostic(format!"Worker system: Event [%s]"(event.kind));
                switch (event.kind)
                {
                    /* Put to the green queue */
                default:
                    greenQueue.put(event);
                    break;
                }
            }
        });
        runTask(&processGreenQueue);
    }

    /**
     * Shutdown the worker system
     */
    void close() @safe
    {
        logInfo("WorkerSystem shutting down");
        _controlQueue.close();
        greenQueue.close();
        distributedQueue.close();
    }

    /**
     * Returns: The controlQueue
     */
    pure @property auto controlQueue() @safe @nogc nothrow
    {
        return _controlQueue;
    }

private:

    /**
     * Process the green queue (multiplexed fibers)
     */
    void processGreenQueue() @safe
    {
        ControlEvent event;
        while (greenQueue.tryConsumeOne(event))
        {
            logInfo(format!"greenQueue: Event [%s]"(event.kind));
        }
    }

    string rootDir;
    ControlQueue _controlQueue;

    /* Multiple threads read from distributed queue */
    ControlQueue distributedQueue;

    /* main thread pulling from a serial queue */
    ControlQueue greenQueue;

    Database appDB;
}
