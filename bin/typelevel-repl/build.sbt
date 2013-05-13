scalaVersion := "2.10.1"

// Scalaz
libraryDependencies ++= Seq(
  "org.scalaz"     %% "scalaz-core"               % "7.0.0",
  "org.scalaz"     %% "scalaz-effect"             % "7.0.0",
  "org.scalaz"     %% "scalaz-typelevel"          % "7.0.0",
  "org.scalaz"     %% "scalaz-scalacheck-binding" % "7.0.0" % "test"
)

// Shapeless
libraryDependencies ++= Seq(
  "com.chuusai" %% "shapeless" % "1.2.4"
)

// Spire
libraryDependencies ++= Seq(
  "org.spire-math" %% "spire" % "0.4.0"
)

// Scalaz-contrib
libraryDependencies ++= Seq(
  "org.typelevel" %% "scalaz-contrib-210"        % "0.1.4",
  "org.typelevel" %% "scalaz-contrib-validation" % "0.1.4",
  "org.typelevel" %% "scalaz-contrib-undo"       % "0.1.4",
  "org.typelevel" %% "scalaz-dispatch"           % "0.1.4",
  "org.typelevel" %% "scalaz-lift"               % "0.1.4",
  "org.typelevel" %% "scalaz-nscala-time"        % "0.1.4",
  "org.typelevel" %% "scalaz-spire"              % "0.1.4"
)

// Shapeless-contrib
libraryDependencies ++= Seq(
  "org.typelevel" %% "shapeless-scalacheck" % "0.1.1",
  "org.typelevel" %% "shapeless-spire"      % "0.1.1",
  "org.typelevel" %% "shapeless-scalaz"     % "0.1.1"
)

scalacOptions += "-feature"

initialCommands in console := "import scalaz._, Scalaz._, shapeless._, spire._"
