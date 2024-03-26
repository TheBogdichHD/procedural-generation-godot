using Godot;
using System;
using System.Collections.Generic;
using ItemInfoName;

public partial class WFC3DModel : Node
{
	Dictionary<Vector3I, int> DirectionToIndex = new Dictionary<Vector3I, int>() {
		[Vector3I.Left] =  2,
		[Vector3I.Right] = 0,
		[Vector3I.Forward] = 1,
		[Vector3I.Back] = 3,
		[Vector3I.Up] = 4,
		[Vector3I.Down] = 5
	};
	
	Dictionary<string, ItemInfo> PrototypeData;
	public List<string>[,,] WaveFunction;
	Vector3I Size;
	public Stack<Vector3I> Stack = new Stack<Vector3I>();
	public Random Rand = new Random();


	public void Initialize(Vector3I NewSize, Dictionary<string, ItemInfo> AllPrototypes)
	{
		Size = NewSize;
		PrototypeData = AllPrototypes;
		WaveFunction = new List<string>[Size.X, Size.Y, Size.Z];

		for (int z = 0; z < Size.Z; z++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int x = 0; x < Size.X; x++)
				{
					WaveFunction[x, y, z] = new List<string>(PrototypeData.Keys);
				}				
			}
		}		
	}
	

	public bool IsCollapsed()
	{
		for (int z = 0; z < Size.Z; z++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int x = 0; x < Size.X; x++)
				{
					if (WaveFunction[x, y, z].Count > 1)
						return false;
				}				
			}
		}	

		return true;
	}
		

	public List<string> GetPossibilities(Vector3I Coords)
	{
		return WaveFunction[Coords.X, Coords.Y, Coords.Z];
	}
		

	public List<string> GetPossibleNeighbours(Vector3I Coords, Vector3I Dir)
	{
		var ValidNeighbours = new List<string>();
		var Prototypes = GetPossibilities(Coords);
		var DirIdx = DirectionToIndex[Dir];

		foreach (string Prototype in Prototypes)
		{
			var Neighbours = PrototypeData[Prototype].ValidNeighbours[DirIdx];

			for (int j = 0; j < Neighbours.Count; j++)
			{
				if (!ValidNeighbours.Contains(Neighbours[j]))
				{
					ValidNeighbours.Add(Neighbours[j]);
				}		
			}			
		}
		
		return ValidNeighbours;
	}
		

	public void CollapseCoordsTo(Vector3I Coords, string PrototypeName)
	{
		WaveFunction[Coords.X, Coords.Y, Coords.Z] = new List<string>() { PrototypeName };
	}


	public void CollapseAt(Vector3I Coords)
	{
		var Selection = WeightedChoice(WaveFunction[Coords.X, Coords.Y, Coords.Z]);
		WaveFunction[Coords.X, Coords.Y, Coords.Z] = new List<string>() { Selection };
	}
		

	public string WeightedChoice(List<string> Prototypes)
	{
		var ProtoWeights = new Dictionary<float, string>();
		
		foreach (string P in Prototypes)
		{
			float W = PrototypeData[P].Weight;
			W += (float)(Rand.NextDouble() * 2 - 1);
			ProtoWeights[W] = P;
		}
			
		var WeightList = new List<float>(ProtoWeights.Keys);
		WeightList.Sort();

		return ProtoWeights[WeightList[^1]];
	}
		

	public void Collapse()
	{
		var Coords = GetMinEntropyCoords();
		CollapseAt(Coords);
	}
		

	public void Constrain(Vector3I Coords, string PrototypeName)
	{
		WaveFunction[Coords.X, Coords.Y, Coords.Z].Remove(PrototypeName);
	}
		

	public float GetEntropy(Vector3I Coords)
	{
		return WaveFunction[Coords.X, Coords.Y, Coords.Z].Count;
	}
		
		
	public Vector3I GetMinEntropyCoords()
	{
		float MinEntropy = int.MaxValue;
		Vector3I Coords = new Vector3I(-1,-1,-1);

		for (int z = 0; z < Size.Z; z++)
		{
			for (int y = 0; y < Size.Y; y++)
			{
				for (int x = 0; x < Size.X; x++)
				{
					var Entropy = GetEntropy(new Vector3I(x, y, z));
					if (Entropy > 1)
					{
						Entropy += (float)(Rand.NextDouble() * 0.2 - 0.1);

						if (MinEntropy == int.MaxValue)
						{	
							MinEntropy = Entropy;
							Coords = new Vector3I(x, y, z);
						}
						else if (Entropy < MinEntropy)
						{
							MinEntropy = Entropy;
							Coords = new Vector3I(x, y, z);
						}							
					}					
				}				
			}
		}	
					
		return Coords;
	}
		

	public void Iterate()
	{
		var Coords = GetMinEntropyCoords();
		CollapseAt(Coords);
		Propagate(Coords);
	}
		

	public void Propagate(Vector3I CoOrds, bool SingleIteration = false)
	{	
		if (CoOrds.X!=-1 && CoOrds.Y!=-1 && CoOrds.Z!=-1)
			Stack.Push(CoOrds);
		
		while (Stack.Count > 0)
		{
			var CurCoords = Stack.Pop();

			foreach (Vector3I D in ValidDirs(CurCoords))
			{
				var OtherCoords = CurCoords + D;
				var PossibleNeighbours = GetPossibleNeighbours(CurCoords, D);
				var OtherPossiblePrototypes = new List<string>(GetPossibilities(OtherCoords));

				if (OtherPossiblePrototypes.Count == 0)
					continue;

				foreach (string OtherPrototype in OtherPossiblePrototypes)
				{
					if (!PossibleNeighbours.Contains(OtherPrototype))
					{
						Constrain(OtherCoords, OtherPrototype);
						if (!Stack.Contains(OtherCoords))
							Stack.Push(OtherCoords);
					}		
				}					
			}
				
			if (SingleIteration)
				break;
		}			
	}
		

	public List<Vector3I> ValidDirs(Vector3I Coords)
	{
		var X = Coords.X;
		var Y = Coords.Y;
		var Z = Coords.Z;

		var Width = Size.X;
		var Height = Size.Y;
		var Length = Size.Z;
		var Dirs = new List<Vector3I>();

		if (X > 0)
			Dirs.Add(Vector3I.Left);
		if (X < Width-1)
			Dirs.Add(Vector3I.Right);
		if (Y > 0)
			Dirs.Add(Vector3I.Down);
		if (Y < Height-1)
			Dirs.Add(Vector3I.Up);
		if (Z > 0)
			Dirs.Add(Vector3I.Forward);
		if (Z < Length-1)
			Dirs.Add(Vector3I.Back);

		return Dirs;
	}
}
