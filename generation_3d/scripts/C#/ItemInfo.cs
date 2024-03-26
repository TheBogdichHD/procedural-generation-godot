using Newtonsoft.Json;
using System.Collections.Generic;

namespace ItemInfoName
{
    public class ItemInfo
    {
    	[JsonProperty("mesh_name")]
    	public string MeshName { get; set; }
    	[JsonProperty("mesh_rotation")]
    	public int MeshRotation { get; set; }
    	[JsonProperty("constrain_to")]
    	public string ConstrainTo { get; set; }
    	[JsonProperty("constrain_from")]
    	public string ConstrainFrom { get; set; }
    	[JsonProperty("weight")]
    	public float Weight { get; set; }
    	[JsonProperty("valid_neighbours")]
    	public List<List<string>> ValidNeighbours { get; set; }
    }
}
