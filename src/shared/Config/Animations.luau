return {
	-- Blender FK action on the canonical MrXen0 R15 rig; evaluated-pose export.
	RunId = "rbxassetid://116051034967244",
	TransitionIds = {
		Start = "rbxassetid://104271079454951", Stop = "rbxassetid://135962042925895",
		Takeoff = "rbxassetid://113531311551794", LandRun = "rbxassetid://123339471651713",
		DoubleJump = "rbxassetid://103031167309210", Fall = "rbxassetid://139218872313289",
		LandIdle = "rbxassetid://85449026426804",
	},
	TransitionDurations = { Start = 8 / 30, Stop = 8 / 30, Takeoff = 10 / 30, DoubleJump = 12 / 30,
		Fall = 12 / 30, LandRun = 6 / 30, LandIdle = 8 / 30 },
	TransitionFade = 0.08,
	MinimumAirPoseTime = 0.18,
	AirHoldLead = 0.07,
	MaxTransitionTime = 1.2,
	BaseSpeed = 20, -- Match the approved preview cadence at normal running speed.
	Fade = 0.12,
	StartFade = 0.18,
	StopFade = 0.20,
	AirFade = 0.08,
	LandingFade = 0.14,
	SpeedResponse = 12, -- Smooth animation cadence only; never physical movement.
	MinimumMovingSpeed = 1.5,
	Duration = 24 / 30,
	UpdateInterval = 0.05,
	FootstepDistance = 150,
	Marker = "Footstep",
	LandingMarker = "Landing",
	ContactTimes = { Left = 0, Right = 12 / 30 },
}
