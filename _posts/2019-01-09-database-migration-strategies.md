---
layout: post
title:  "Database migration strategies"
date:   2019-01-09 14:24:37 -0800
---
Most web applications use a database to persist state.
Since the database is separate from the application and changes cannot be made to both simultaneously, there are various strategies for keeping them in sync.

## Fully-coupled

Many web applications are deployed by:

1. stopping the application
2. running any database migrations
3. deploying and starting the new application

If a problem is discovered during the deploy, the database change must be rolled back and the old version of the application must be redeployed.

This is a simple approach that does not require backwards- or forwards-compatibility between the old and new application and database versions since it is assumed that both the application and database will be running either the old or new versions.

A downside to this approach is that it requires the application to go offline during deploys, causing some period of unavailability.

## Partially-coupled

In order to provide zero-downtime deployments, another strategy exists involving [blue-green deployment](https://martinfowler.com/bliki/BlueGreenDeployment.html).

### Pre-deploy migrations

An example of such an approach could involve multiple application servers running against a single database instance where during a deploy:

1. the database is migrated to the new version
2. the new application is deployed to application servers in groups and bounced so that at any one time some servers are running the old application code and the new application code
3. until eventually all application servers are running the new application code

Since multiple application servers are used and at any point in time at least some are running, there is no period of unavailability.

This approach requires the new database version to be backwards-compatible with the old application version (which would be equivalent to saying the old application version must be forwards-compatible with the new database version) since any server could be running either the old or new application code.

This approach does *not* require the old database version to be forwards-compatible with the new application version (which would be equivalent to saying the new application version does not have to be backwards-compatible with the old database version) since it can always be assumed that if an application server is running the new code, the database changes have already be made due to the fact that the database migration is always run prior to deploying the new code.

However this also means that if a problem is discovered after the deploy and the database needs to be rolled back, the application *must also* be rolled back first.

A downside to this approach is that it still requires database migrations to be run prior to application deploys, which means long-running database migrations can hold up application deploys.

### Post-deploy migrations

An alternative to this approach could be to reverse the order and do database migrations at the end of deploys, which would invert the backwards- and forwards-compatibility.
That is, it would require the new application version to be backwards-compatible with the old database version (but not require the new database version to be backwards-compatible with the old application version).

This also means that if a problem is discovered after the deploy and the application needs to be rolled back, the database *must also* be rolled back.

However, the problem of database migrations holding up a deploy still applies in either case; it would just be shifted to happening later.

This alternative is not usually chosen since additive changes are more common.
Consider the example of adding a new column.

In the pre-migration approach, the database change happens first and then the new application code is deployed.
This means the new application code can then assume that the column will be present (though of course the old application code still needs to work with and without the new column but this is usually easily done e.g. by selecting specific columns instead of `select *`).

In the post-migration approach, the new application code cannot assume the column is present.
This would require the new application code to conditionally handle either case, adding complexity, or more likely, spreading out the change over two releases (adding the column in the first release and then using it in the second).
The tradeoff is that the old application code need not work with the new column since it would never be run with it present.

The benefit of the post-migration approach is more apparent when we consider the example of removing a column (ignoring the specific issues that stem from Rails caching columns that necessitate [ignoring columns](https://github.com/rails/rails/pull/21720) prior to dropping them even when the application no longer uses the column).

In the pre-migration approach, the column is removed before the new code is deployed.
This would necessitate the old code to work without the column that is about to be removed, which would require conditionally handling either case (again adding complexity), or more commonly, would require two releases.

In the post-migration approach, the new code is deployed before the column is removed so it can be safely dropped as no running apps will attempt to use it.

If you had to pick between having either pre- or post-migrations only, it's more common to choose pre-migrations since applications additive changes like adding columns are usually more common than subtractive changes like removing columns.

### Both pre- and post-deploy migrations

Given the tradeoffs to these approaches, there is of course another approach possible: to run some migrations before the new code is deployed and some after.

This approach has added complexity since most database migration tooling (e.g. Active Record migrations) is built with the assumption of just running all of the migrations available.

There is also conceptual overhead required in having to think through when any particular migration should be run and how to handle rollbacks.

This approach also still has the problem of long-running migrations holding up an app release.

## Zero-coupling

In all of the previously mentioned approaches, performing the database migration at a specified point during a release along with an application deploy affords not having to maintain either backwards- or forwards-compatibility (though not both except in the first case).

Of course, it is possible to forgo this affordance and instead strive for both backwards- and forwards-compatibility even when not strictly necessary, removing the problem of having to rollback the application and database together.

However once you do that, you might as well consider one final possible approach: to fully decouple application and database changes so that either can occur in isolation.

A simple way of implementing this approach while keeping a single release pipeline would be to have each release contain either application changes or database changes, but not both.

This would require maintaining both backwards- and forwards-compatibility, which adds some conceptual overhead, but also provides confidence for rollbacks.

Each change could also be rolled back in isolation since at any point:
1. when deploying the application, the database must support both the old and new application versions
2. when migrating the database, the application must support both the old and new database versions

If some additional work is taken to separate the release pipelines, this approach could provide the capability to deploy application changes at any time, whether a database migration is currently running or not.

## Conclusion

Each approach outlined above has tradeoffs. As coupling decreases, the conceptual overhead required to understand the necessary backwards- and/or forwards-compatibility quickly increases.

It's often assumed that the work necessary to decouple application changes from database changes is not worth pursuing until reaching a certain scale, but as soon as they are partially decoupled (for zero-downtime deployment), it becomes essential to consider the need for backwards- and forwards-compatibility. I believe that it may prove to be worth it to expend the additional effort to fully decouple application and database changes early on to establish good habits and provide confidence for rollbacks.

Whichever approach you take, it's important to understand the possible problems that can emerge from the fundamental problem of the database and application not existing as a single entity that can be changed atomically.

## Prior work

The following blog posts greatly helped me formulate my thoughts more concretely on this subject:

1. Philip Potter - [Keep database deploys separate](http://www.philandstuff.com/2018/04/04/keep-database-deploys-separate.html)
2. Michael Brunton-Spall - [Database Migrations Done Right](http://www.brunton-spall.co.uk/post/2014/05/06/database-migrations-done-right/)
3. Philip I. Thomas - [Don't Migrate Databases Automatically](https://blog.staffjoy.com/dont-migrate-databases-automatically-5039ab061365)
