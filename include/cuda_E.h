////////////////////////////////////////////////
//  h file contains the operation with cuda   //
////////////////////////////////////////////////

int cudaSetDeviceTorque(){
	//set the working device to be what the torque system has assigned and return the device id (>=0) being in use
	//when task is not submitted via pbs, retrn -1 and do nothing in setting device
	//system error or other situation return -2

	int dev_id=0;
	FILE *fp;
	if ((fp=popen("if [ ! $PBS_GPUFILE ];then echo -1;else cat $PBS_GPUFILE|awk -F'u' '{print$2}'; fi","r"))==NULL){ 
		return -2;
	}else{ fscanf(fp,"%d",&dev_id); }
	fclose(fp);
	if (dev_id>=0) cudaSetDevice(dev_id);
	return dev_id;
}
int cudaSetDeviceTorque(int id){
	cudaSetDevice(id);
	return id;
}
