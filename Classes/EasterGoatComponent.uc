class EasterGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var StaticMeshComponent mMaskMesh;
var SkeletalMesh mGoatMesh;
var Material mWhiteMat;

var float mDefaultJumpZ;
var float mDefaultSpeed;

var float timeElapsed;
var float managementTimer;
var float mEggRadius;
var int mMinEggsCount;

var bool mHintVisible;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;
		GGGameInfo( gMe.WorldInfo.Game ).SpawnMutator( gMe, class'GGMutatorInventory' );

		// Avoid ragdolling after big jumps
		gMe.mCanRagdollByVelocityOrImpact=false;
		// Add bunny mask
		if(!IsZero(gMe.mesh.GetBoneLocation('Head')))
		{
			gMe.mesh.AttachComponent(mMaskMesh, 'Head', vect(0, 0, 0), rot( 0, 0, 0 ));
		}
		else
		{
			gMe.AttachComponent(mMaskMesh);
		}
		mMaskMesh.SetLightEnvironment( gMe.mesh.lightenvironment );

		//White color for goat
		if(gMe.Mesh.SkeletalMesh == mGoatMesh)
		{
			gMe.mesh.SetMaterial(0, mWhiteMat);
		}

		mDefaultJumpZ=gMe.JumpZ;
		mDefaultSpeed=gMe.mSprintSpeed;
	}
}

function TickMutatorComponent( float deltaTime )
{
 	timeElapsed=timeElapsed+deltaTime;
	if(timeElapsed > managementTimer)
	{
		timeElapsed=0.f;
		UpdateJumpHeightAndSpeed();
		SpawnEggsAround();
	}

	ManageHint();
}

function UpdateJumpHeightAndSpeed()
{
	local int eggCount;

	eggCount=CountEggsCollected();

 	gMe.JumpZ=mDefaultJumpZ + (50 * eggCount);
 	gMe.mSprintSpeed = mDefaultSpeed + (100 * eggCount);
}

function int CountEggsCollected()
{
	local int i, eggCount;
	local GGInventory inv;

	inv=gMe.mInventory;

	if(inv == none)
		return 0;

	eggCount=0;
	for(i=0 ; i<inv.mInventorySlots.Length ; i++)
	{
		if(EasterEgg(inv.mInventorySlots[i].mItem) != none)
		{
			eggCount++;
		}
	}

	return eggCount;
}

function SpawnEggsAround()
{
 	local EasterEgg egg, newEgg;
 	local int eggCount, eggsToSpawn;
 	local vector dist;

	//Find all easter eggs near goat
	foreach gMe.AllActors(class'EasterEgg', egg)
	{
		dist=GetPosition(gMe) - egg.StaticMeshComponent.GetPosition();
		if(VSize2D(dist) < mEggRadius)
		{
			eggCount++;
		}
	}
	// Spawn new eggs to match min count
	eggsToSpawn = mMinEggsCount - eggCount;
	while(eggsToSpawn > 0)
	{
		newEgg=gMe.Spawn(class'EasterEgg',,, GetRandomSpawnLocation(GetPosition(gMe)), GetRandomRotation());
		newEgg.InitEgg();
		eggsToSpawn--;
	}
}

function vector GetRandomSpawnLocation(vector center)
{
	local vector dest;
	local rotator rot;
	local float dist;
	local Actor hitActor;
	local vector hitLocation, hitNormal, traceEnd, traceStart;

	rot=GetRandomRotation();

	dist=mEggRadius;
	dist=RandRange(dist/2.f, dist);

	dest=center+Normal(Vector(rot))*dist;
	traceStart=dest;
	traceEnd=dest;
	traceStart.Z=10000.f;
	traceEnd.Z=-3000;

	hitActor = gMe.Trace( hitLocation, hitNormal, traceEnd, traceStart, true);
	if( hitActor == none )
	{
		hitLocation = traceEnd;
	}

	hitLocation.Z+=10;

	return hitLocation;
}

function rotator GetRandomRotation()
{
	local rotator rot;

	rot=Rotator(vect(1, 0, 0));
	rot.Yaw+=RandRange(0.f, 65536.f);

	return rot;
}

function vector GetPosition(Pawn pwn)
{
	if(pwn.Physics == PHYS_RigidBody)
		return pwn.Mesh.GetPosition();
	else
		return pwn.Location;
}

function ManageHint()
{
	if(gMe.mGrabbedItem == none)
	{
		if(mHintVisible)
			RemoveEggHint("eggHint");
	}
	else if(EasterEgg(gMe.mGrabbedItem) != none)
	{
		if(!mHintVisible && CountEggsCollected() == 0)
			ShowEggHint("eggHint", 10);
	}
}

function ShowEggHint(string hintName, int hintPriority)
{
	local GGPlayerControllerGame goatController;
	local string message;

	goatController = GGPlayerControllerGame( gMe.Controller );

	if(goatController == none)
		return;

	message = "Add egg to inventory for extra jump height and speed!";
	goatController.AddHintLabelMessage( hintName, message, hintPriority );
	mHintVisible=true;
}

function RemoveEggHint(string hintName)
{
	local GGPlayerControllerGame goatController;

	goatController = GGPlayerControllerGame( gMe.Controller );

	if( goatController == none )
	{
		goatController = GGPlayerControllerGame( gMe.DrivenVehicle.Controller );
	}

	if( goatController != none )
	{
		goatController.RemoveHintLabelMessage( hintName );
		mHintVisible=false;
	}
}

defaultproperties
{
	managementTimer=1.f
	mEggRadius=5000.f
	mMinEggsCount=5

	Begin Object class=StaticMeshComponent Name=maskMesh
		StaticMesh=StaticMesh'Heist_Masks_01.mesh.Rabbit_01'
	End Object
	mMaskMesh=maskMesh

	mGoatMesh=SkeletalMesh'goat.mesh.goat'
	mWhiteMat=Material'goat.Materials.Goat_Mat_05'
}