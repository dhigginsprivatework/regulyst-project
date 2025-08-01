import { LightningElement, api, track } from 'lwc';
import getPromptDetails from '@salesforce/apex/GenerateAiInsightsController.getPromptDetails';
import getCopilotResponse from '@salesforce/apex/CopilotCalloutService.getCopilotResponse';
import updateAISummary from '@salesforce/apex/GenerateAiInsightsController.updateAISummary';

export default class GenerateAiInsights extends LightningElement {
  @api recordId;
  @track aiSummary;
  isLoading = false;
  error;

  async handleGenerate() {
    this.isLoading = true;
    this.error = null;
    this.aiSummary = null;

    try {
      const prompt = await getPromptDetails({ evidenceId: this.recordId });

      const aiResponse = await getCopilotResponse({
        prompt,
        evidenceId: this.recordId
      });

      await updateAISummary({
        evidenceId: this.recordId,
        summaryText: aiResponse
      });

      this.aiSummary = aiResponse;
    } catch (err) {
      this.error = err.body?.message || err.message;
    } finally {
      this.isLoading = false;
    }
  }
}