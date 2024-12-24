"""
This file generate HPN 7.0 architecture in one POD, thus no DSW will be generated.
The GPU used in POD is H800 and the nic is Mellanox BF3.
"""
import argparse
# NVLINK Bandwidth - A100: 2400Gbps, H200: 1700Gbps, H100/H20: 3600Gbps

def gen_DCN_single_plane(args):
    asw_switch_num = args.asw_switch_num
    nv_switch_num = (int)(args.gpu / args.gpu_per_server) * args.nv_switch_per_server
    nodes_per_2asw = args.nics_per_aswitch # 每个asw下行连接数
    nodes = (int) (args.gpu + asw_switch_num + args.psw_switch_num + nv_switch_num) # 
    servers = args.gpu / args.gpu_per_server
    switch_nodes = (int)(args.psw_switch_num + asw_switch_num + nv_switch_num) # 
    links = (int)((args.psw_switch_num / 2) * asw_switch_num + servers * args.gpu_per_server+ servers * args.nv_switch_per_server * args.gpu_per_server) # 

    # for verification
    gpu_to_links = {}
    # file_name = "../network-topologies/"+"DCN_"+str(args.gpu)+"_gpus_"+str(args.gpu_per_server)+"_in_one_server_with_single_plane_"+args.bandwidth+"_"+args.gpu_type
    file_name = "./../network-topologies/"+"topo"
    with open(file_name, 'w') as f:
        print(file_name)
        first_line = str(nodes)+" "+str(switch_nodes)+" "+str(int(links))
        f.write(first_line)
        f.write('\n')
        nv_switch = []
        asw_switch_1 = []
        psw_switch_1 = []
        psw_switch_2 = []
        sec_line = ""
        nnodes = nodes - switch_nodes
        for i in range(nnodes, nodes):
            sec_line = sec_line + str(i) + " "
            if len(nv_switch) < nv_switch_num:
                nv_switch.append(i)
            elif len(asw_switch_1) < asw_switch_num:
                asw_switch_1.append(i)
            elif len(psw_switch_1) < args.psw_switch_num / 2:
                psw_switch_1.append(i)
            else:
                psw_switch_2.append(i)
        f.write(sec_line)
        f.write('\n')
        
        ind_asw1 = 0
        curr_node = 0
        ind_nv = 0
        asw_node = 0
        cnt = 0
        for i in range(args.gpu):
            curr_node = curr_node + 1
            asw_node = asw_node + 1
            if curr_node > args.gpu_per_server:
                curr_node = 1
                ind_nv = ind_nv + args.nv_switch_per_server
            
            for j in range(0, args.nv_switch_per_server):
                cnt += 1
                line = str(i)+" "+str(nv_switch[ind_nv+j])+" "+args.nvlink_bw+" "+args.nv_latency+" "+args.error_rate
                f.write(line)
                f.write('\n')

            if asw_node > nodes_per_2asw:
                asw_node = 1
                ind_asw1 = ind_asw1 + 1

            line = str(i)+" "+str(asw_switch_1[ind_asw1])+" "+args.bandwidth+" "+args.latency+" "+args.error_rate
            f.write(line)
            f.write('\n')
            
        # double logical plane
        for i in asw_switch_1: # asw - psw
            for j in psw_switch_1:
                line = str(i) + " " + str(j) +" "+ args.ap_bandwidth+" " + args.latency+" " +args.error_rate
                f.write(line)
                f.write('\n')

def main():
    parser = argparse.ArgumentParser(description='Python script for generate the HPN 7.0 network topo')
    parser.add_argument('-l','--latency',type=str,default='0.0005ms',help='nic latency,default 0.0005ms')
    parser.add_argument('-nl','--nv_latency',type=str,default='0.000025ms',help='nv switch latency,default 0.000025ms')
    parser.add_argument('-bw','--bandwidth',type=str,default='100Gbps',help='nic to asw bandwitch,default 100Gbps')
    parser.add_argument('-apbw','--ap_bandwidth',type=str,default='100Gbps',help='asw to psw bandwitch,default 100Gbps')
    parser.add_argument('-nvbw','--nvlink_bw',type=str,default='1700Gbps',help='nvlink_bw,default 1700Gbps')
    parser.add_argument('-er','--error_rate',type=str,default='0',help='error_rate,default 0')
    parser.add_argument('-g','--gpu',type=int,default=1024,help='gpus num,default 32')
    parser.add_argument('-gt','--gpu_type',type=str,default='H800',help='gpu_type,default H800')
    parser.add_argument('-gps','--gpu_per_server',type=int,default=1,help='gpu_per_server,default 1')
    parser.add_argument('-psn','--psw_switch_num',type=int,default=128,help='psw_switch_num,default 128')
    parser.add_argument('-asn','--asw_switch_num',type=int,default=64,help='asw_switch_num,default 64')
    parser.add_argument('-nsps','--nv_switch_per_server',type=int,default=0,help='nv_switch_per_server,default 1')
    parser.add_argument('-npa','--nics_per_aswitch',type=int,default=16,help='nnics per asw,default 16')
    args = parser.parse_args()
    gen_DCN_single_plane(args)

if __name__ =='__main__':
    main()
    







