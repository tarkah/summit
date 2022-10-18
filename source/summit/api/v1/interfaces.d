/*
 * SPDX-FileCopyrightText: Copyright © 2020-2022 Serpent OS Developers
 *
 * SPDX-License-Identifier: Zlib
 */

/**
 * summit.api.v1.interfaces
 *
 * V1 Summit API Interfaces
 *
 * Authors: Copyright © 2020-2022 Serpent OS Developers
 * License: Zlib
 */

module summit.api.v1.interfaces;

public import vibe.d;

/**
 * A ListItem can be represented using a specific ListContext
 */
public enum ListContext : string
{
    Collections = "collections",
    Users = "users",
    Groups = "groups",
    Repositories = "repositories",
}

/**
 * Used for marshalling a ListContext item in JS
 */
public struct ListItem
{
    /**
     * What context does this belong in?
     */
    ListContext context;

    /**
     * Unique identifier
     */
    string id;

    /**
     * Full slug URI
     */
    string slug;

    /**
     * The title for the item
     */
    string title;

    /**
     * Subtitle / summary
     */
    string subtitle;

    /**
     * An item may have children too
     */
    ListItem[] children;
}

/**
 * Root API node
 */
@path("/api/v1")
public interface SummitAPIv1
{
    /**
     * Return the actual version identifier
     */
    @path("version") @method(HTTPMethod.GET) pure string versionID() @safe @nogc nothrow const;
}
